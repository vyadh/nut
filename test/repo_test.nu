use std/assert
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
def "cache creates bare repo directly into target folder" [] {
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

    # The cache is not updated on clone
    $local | repo cache $remote
    cd $local
    let tags = git tag | complete | get stdout | str trim
    assert equal ($tags) "v1.0.0"
}

def create-remote []: string -> nothing {
    let remote = $in
    mkdir $remote
    cd $remote
    git init --initial-branch=main
    "print test" | save "main.nu"
    git add "main.nu"
    git commit --message "Initial commit"
    git tag "v1.0.0"
}
