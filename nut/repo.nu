
export def cache [remote: string]: string -> nothing {
    let path = $in

    if not ($path | path exists) {
        exec { git clone --bare $remote $path }
    }
}

export def update []: string -> nothing {
    let path = $in
    cd $path

    exec { git fetch --tags }; ignore
}

export def tags []: string -> list<record<created: datetime, name: string>> {
    let path = $in
    cd $path

    let format = '{ created: "%(creatordate:iso8601-strict)" name: "%(refname:short)" }'

    exec { git for-each-ref --sort=creatordate --format $format refs/tags }
        | $"([$in])"
        | from nuon
        | upsert created { |row|
            $row.created | into datetime --format %+
        }
}

export def "work create" [repo: string, ref: string]: string -> nothing {
    let path = $in
    cd $repo

    exec { git worktree add --detach $path $ref }; ignore
}

export def "work list" []: string -> table<path: string, revision: string> {
    let path = $in
    cd $path

    exec { git worktree list --porcelain }
        | split row "\n\n"
        | each { parse "worktree {path}\nHEAD {revision}\ndetached" }
        | flatten
}

def exec [cmd: closure]: nothing -> string {
    let result = do $cmd | complete

    if $result.exit_code != 0 {
        error make { msg: ($result.stderr | str trim) }
    }

    $result.stdout
}
