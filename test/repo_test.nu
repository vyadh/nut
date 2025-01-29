use std assert
use std null-device
use ../nut/repo.nu

# [ignore]
def test []: nothing -> nothing {
    git worktree add --detach "work-71bc3d2" "71bc3d2b5fc3804ee70bfff2804c21ac4e9cf2a5"
    git worktree list --porcelain
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
def "cache fails with error with message from git" [] {
    let remote = $in.remote
    let local = $in.local

    try {
        $local | repo cache $remote
        assert false "should throw error"
    } catch { |error|
        assert equal ($error | get msg) $"fatal: repository '($remote)' does not exist"
    }
}

# [test]
def "cache clones bare repo into target folder" [] {
    let remote = $in.remote
    let local = $in.local
    $remote | create-repo

    $local | repo cache $remote

    assert ($local | path join "refs" | path exists) "local folder is git repo"
}

# [test]
def "cache makes takes no updates automatically" [] {
    let remote = $in.remote
    let local = $in.local
    $remote | create-repo
    $remote | tag "v1.0.0"

    # First clone the remote
    $local | repo cache $remote

    # When a change is made to remote
    $remote | tag "v2.0.0"

    # The local repo is not updated on cache
    $local | repo cache $remote
    cd $local
    let tags = git tag | complete | get stdout | str trim
    assert equal ($tags) "v1.0.0"
}

# [test]
def "update fails with error with message from git" [] {
    let local = $in.local
    mkdir $local

    try {
        $local | repo update
        assert false "should throw error"
    } catch { |error|
        assert equal ($error | get msg) "fatal: not a git repository (or any of the parent directories): .git"
    }
}

# [test]
def "update fetches new content" [] {
    let remote = $in.remote
    let local = $in.local
    $remote | create-repo
    $remote | tag "v1.0.0"

    # Cache the remote
    $local | repo cache $remote

    # When a change is made to remote
    $remote | commit-file "other.nu" "print other"
    $remote | tag "v2.0.0"

    # The cache is updated
    $local | repo update
    cd $local
    let tags = git tag | complete | get stdout | str trim
    assert equal ($tags) "v1.0.0\nv2.0.0"
}

# [test]
def "tags fails with error with message from git" [] {
    let local = $in.local
    mkdir $local

    try {
        $local | repo tags
        assert false "should throw error"
    } catch { |error|
        assert equal ($error | get msg) "fatal: not a git repository (or any of the parent directories): .git"
    }
}

# [test]
def "tags lists all tags and only tags" [] {
    let remote = $in.remote
    let local = $in.local
    $remote | create-repo
    $remote | tag "v1.0.0"
    $remote | commit-file "other.nu" "print other"
    $remote | tag "v2.0.0"
    $local | repo cache $remote

    let tags = $local | repo tags

    assert equal ($tags | reject created) [
        { name: "v1.0.0" }
        { name: "v2.0.0" }
    ]
    for $tag in $tags {
        let recently = (date now) - 10sec
        assert ($tag.created > $recently)
    }
}

def create-repo []: string -> nothing {
    let path = $in
    mkdir $path
    cd $path

    git init --quiet --initial-branch=main
    $path | commit-file "main.nu" "print main"
}

def tag [tag: string]: string -> nothing {
    let path = $in
    cd $path

    git tag $tag
}

def commit-file [file: string, content: string]: string -> nothing {
    let path = $in
    cd $path

    $"print ($content)" | save $file
    git add $file
    git commit --quiet --message $"Add ($file)"
}
