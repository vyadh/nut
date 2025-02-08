
export def clone [remote: string]: string -> nothing {
    let path = $in

    if not ($path | path exists) {
        git clone --bare $remote $path
    }
}

# todo merge with cache or indicate whether cache already existed?
export def update []: string -> nothing {
    let path = $in
    cd $path

    git fetch --tags; ignore
}

export def tags []: string -> list<record<created: datetime, commit: string, tag: string>> {
    let path = $in
    cd $path

    let format = '{ created: "%(creatordate:iso8601-strict)" commit: "%(objectname)" tag : "%(refname:short)" }'

    git for-each-ref --sort=creatordate --format $format refs/tags
        | $"([$in])"
        | from nuon
        | upsert created { |row|
            $row.created | into datetime --format %+
        }
}

export def "work create" [clone: path, ref: string]: path -> path {
    let worktree = $in
    cd $clone

    git worktree add --detach $worktree $ref

    $worktree
}

export def "work list" []: path -> table<path: string, revision: string> {
    let clone = $in
    cd $clone

    git worktree list --porcelain
        | split row "\n\n"
        | each { parse "worktree {path}\nHEAD {revision}\ndetached" }
        | flatten
}

export def "work upsert" [clone: path, revision: string]: path -> string {
    let worktree = $in

    let existing = $clone
        | work list
        | where revision == $revision
        | get path

    if ($existing | is-empty) and ($worktree | path exists) {
        error make { msg: $"Directory already exists at: ($worktree)" }
    } else if ($existing | is-not-empty) and (($existing | first) != $worktree) {
        error make { msg: $"Worktree already exists at: ($existing | first)" }
    } else if ($existing | is-not-empty) and ($worktree | path exists) {
        # Reuse existing worktree
        $worktree
    } else {
        $worktree | work create $clone $revision
    }
}

def --wrapped git [...args: string]: nothing -> string {
    let result = ^git ...$args | complete

    if $result.exit_code != 0 {
        error make { msg: ($result.stderr | str trim) }
    }

    $result.stdout
}
