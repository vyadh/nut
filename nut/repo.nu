
export def cache [remote: string]: string -> nothing {
    let path = $in

    if not ($path | path exists) {
        git clone --bare $remote $path
    }
}

export def update []: string -> nothing {
    let path = $in
    cd $path

    git fetch --tags; ignore
}

export def tags []: string -> list<record<created: datetime, name: string>> {
    let path = $in
    cd $path

    let format = '{ created: "%(creatordate:iso8601-strict)" name: "%(refname:short)" }'

    git for-each-ref --sort=creatordate --format $format refs/tags
        | $"([$in])"
        | from nuon
        | upsert created { |row|
            $row.created | into datetime --format %+
        }
}

export def "work create" [repo: string, ref: string]: string -> nothing {
    let path = $in
    cd $repo

    git worktree add --detach $path $ref; ignore
}

export def "work list" []: string -> table<path: string, revision: string> {
    let path = $in
    cd $path

    git worktree list --porcelain
        | split row "\n\n"
        | each { parse "worktree {path}\nHEAD {revision}\ndetached" }
        | flatten
}

def --wrapped git [...args: string]: nothing -> string {
    let result = ^git ...$args | complete

    if $result.exit_code != 0 {
        error make { msg: ($result.stderr | str trim) }
    }

    $result.stdout
}
