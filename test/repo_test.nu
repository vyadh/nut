use std assert
use std null-device
use ../nut/repo.nu

# [ignore]
def test []: nothing -> nothing {
    git clone --bare "https://github.com/vyadh/nutest.git"

    git worktree add --detach "work-71bc3d2" "71bc3d2b5fc3804ee70bfff2804c21ac4e9cf2a5"

    git worktree list --porcelain

    git for-each-ref --sort=creatordate --format '{ created: "%(creatordate:iso8601-strict)" name: "%(refname:short)"} ' refs/tags
        | complete
        | get stdout | $"([$in])"
        | from nuon
        | upsert created { |row | $row.created | into datetime --format %+ }

    print "test"
}

# [before-each]
def init []: nothing -> record {
    let dir = mktemp --directory
    let remote = $dir | path join "remote"
    let local = $dir | path join "local"

    {
        dir: $dir
        remote: $remote
        local: $local
    }
}

# [after-each]
def remove []: nothing -> nothing {
    rm --recursive --force $in.dir
}

# [test]
def "cache clones bare repo into target folder" [] {
    let remote = $in.remote
    let local = $in.local
    $remote | create-remote

    $local | repo cache $remote

    assert ($local | path join "refs" | path exists) "local folder is git repo"
}

# [test]
def "cache makes takes no updates automatically" [] {
    let remote = $in.remote
    let local = $in.local
    $remote | create-remote

    # First clone the remote
    $local | repo cache $remote

    # When a change is made to remote
    cd $remote
    git tag "v2.0.0"

    # The cache is not updated on cache
    $local | repo cache $remote
    cd $local
    let tags = git tag | complete | get stdout | str trim
    assert equal ($tags) "v1.0.0"
}

# [test]
def "update fetches new content" [] {
    let remote = $in.remote
    let local = $in.local
    $remote | create-remote

    # First clone the remote
    $local | repo cache $remote

    # When a change is made to remote
    cd $remote
    commit-file "other.nu" "print other"
    git tag "v2.0.0"

    # The cache is updated
    $local | repo update
    cd $local
    let tags = git tag | complete | get stdout | str trim
    assert equal ($tags) "v1.0.0\nv2.0.0"
}

def create-remote []: string -> nothing {
    let remote = $in
    mkdir $remote
    cd $remote
    git init --quiet --initial-branch=main
    commit-file "main.nu" "print main"
    git tag "v1.0.0"
}

def commit-file [path: string, content: string] {
    $"print ($content)" | save $path
    git add $path
    git commit --quiet --message $"Add ($path)"
}
