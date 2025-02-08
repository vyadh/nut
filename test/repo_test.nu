use std assert
use std null-device
use ../nut/repo.nu
use errors.nu catch-error

# [before-each]
def init []: nothing -> record {
    let dir = mktemp --directory
    let remote = $dir | path join "remote"
    let clone = $dir | path join "clone"

    {
        dir: $dir
        remote: $remote
        clone: $clone
    }
}

# [after-each]
def remove []: nothing -> nothing {
    rm --recursive --force $in.dir
}

# [test]
def "clone fails with error with message from git" [] {
    let remote = $in.remote
    let clone = $in.clone

    try {
        $clone | repo clone $remote
        assert false "should throw error"
    } catch { |error|
        assert equal ($error | get msg) $"fatal: repository '($remote)' does not exist"
    }
}

# [test]
def "clone clone remote repo in target folder as bare" [] {
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo

    $clone | repo clone $remote

    assert ($clone | path join "refs" | path exists) "clone folder is git repo"
}

# [test]
def "clone makes takes no updates automatically" [] {
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | tag "v1.0.0"

    # First clone the remote
    $clone | repo clone $remote

    # When a change is made to remote
    $remote | tag "v2.0.0"

    # The repo is not updated given already cloned
    $clone | repo clone $remote
    cd $clone
    let tags = git tag | complete | get stdout | str trim
    assert equal ($tags) "v1.0.0"
}

# [test]
def "update fails with error with message from git" [] {
    let clone = $in.clone
    mkdir $clone

    try {
        $clone | repo update
        assert false "should throw error"
    } catch { |error|
        assert equal ($error | get msg) "fatal: not a git repository (or any of the parent directories): .git"
    }
}

# [test]
def "update fetches new content" [] {
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | tag "v1.0.0"

    # Clone the remote
    $clone | repo clone $remote

    # When a change is made to remote
    $remote | commit-file "other.nu" "print other"
    $remote | tag "v2.0.0"

    # The clone is updated
    $clone | repo update
    cd $clone
    let tags = git tag | complete | get stdout | str trim
    assert equal ($tags) "v1.0.0\nv2.0.0"
}

# [test]
def "tags fails with error with message from git" [] {
    let clone = $in.clone
    mkdir $clone

    try {
        $clone | repo tags
        assert false "should throw error"
    } catch { |error|
        assert equal ($error | get msg) "fatal: not a git repository (or any of the parent directories): .git"
    }
}

# [test]
def "tags lists all tags and only tags" [] {
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | tag "v1.0.0"
    $remote | commit-file "other.nu" "print other"
    $remote | tag "v2.0.0"
    $clone | repo clone $remote

    let tags = $clone | repo tags

    assert equal ($tags | reject created commit) [
        { tag: "v1.0.0" }
        { tag: "v2.0.0" }
    ]
    for $tag in $tags {
        let recently = (date now) - 10sec
        assert ($tag.created > $recently)

        assert ($tag.commit like '[0-9a-f]{40}')
    }
}

# [test]
def "work create exports worktrees to target path" [] {
    let dir = $in.dir
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | commit-file "one.nu" "print one"
    $remote | tag "v1.0.0"
    $remote | commit-file "two.nu" "print two"
    $remote | tag "v2.0.0"
    $clone | repo clone $remote

    let work1 = $dir | path join "work1"
    let work2 = $dir | path join "work2"
    $work1 | repo work create $clone "refs/tags/v1.0.0"
    $work2 | repo work create $clone "refs/tags/v2.0.0"

    assert ($work1 | path join "one.nu" | path exists)
    assert ($work2 | path join "one.nu" | path exists)
    assert not ($work1 | path join "two.nu" | path exists) "work1 does not have two.nu"
    assert ($work2 | path join "two.nu" | path exists)
}

# [test]
def "work list shows existing worktrees" [] {
    let dir = $in.dir
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | commit-file "one.nu" "print one"
    $remote | tag "v1.0.0"
    $remote | commit-file "two.nu" "print two"
    $remote | tag "v2.0.0"
    $clone | repo clone $remote
    let work1 = $dir | path join "work1"
    let work2 = $dir | path join "work2"
    $work1 | repo work create $clone "refs/tags/v1.0.0"
    $work2 | repo work create $clone "refs/tags/v2.0.0"

    let worktrees = $clone | repo work list

    assert equal $worktrees [
        { path: $work1, revision: ($work1 | revision) }
        { path: $work2, revision: ($work2 | revision) }
    ]
}

# [test]
def "work upsert creates worktree if missing" [] {
    let dir = $in.dir
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | commit-file "file.nu" "print file"
    $remote | tag "v1.0.0"
    $clone | repo clone $remote
    let work = $dir | path join "work"

    let work_path = $work | repo work upsert $clone "refs/tags/v1.0.0"

    assert equal $work_path $work
    assert equal (open --raw ($work | path join "file.nu")) "print file"
}

# [test]
def "work upsert reuses existing tracked worktree" [] {
    let dir = $in.dir
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | commit-file "file.nu" "print file"
    $remote | tag "v1.0.0"
    $clone | repo clone $remote
    let revision = $clone | repo tags | first | get commit
    let existing = $dir | path join "worktree" | repo work create $clone $revision

    let worktree = $existing | repo work upsert $clone $revision

    assert equal $worktree $existing
    assert equal (open --raw ($worktree | path join "file.nu")) "print file"
}

# [test]
def "work upsert fails if worktree directory already exists" [] {
    let dir = $in.dir
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | commit-file "file.nu" "print file"
    $remote | tag "v1.0.0"
    $clone | repo clone $remote
    let revision = $clone | repo tags | first | get commit
    let existing = $dir
    mkdir $existing

    let error = catch-error { $existing | repo work upsert $clone $revision }

    assert equal $error $"Directory already exists at: ($existing)"
}

# [test]
def "work upsert fails when creating duplicate worktree" [] {
    let dir = $in.dir
    let remote = $in.remote
    let clone = $in.clone
    $remote | create-repo
    $remote | commit-file "file.nu" "print file"
    $remote | tag "v1.0.0"
    $clone | repo clone $remote
    let revision = $clone | repo tags | first | get commit
    let worktree1 = $dir | path join "worktree1" | repo work create $clone $revision
    let worktree2 = $dir | path join "worktree2"

    let error = catch-error { $worktree2 | repo work upsert $clone $revision }

    assert equal $error $"Worktree already exists at: ($worktree1)"
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

    $content | save $file
    git add $file
    git commit --quiet --message $"Add ($file)"
}

def revision []: string -> string {
    let path = $in
    cd $path

    git rev-parse HEAD | complete | get stdout | str trim
}
