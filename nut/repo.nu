
export def cache [remote: string]: string -> nothing {
    let path = $in

    if not ($path | path exists) {
        git clone --bare $remote $path
    }
}

export def update []: string -> nothing {
    let path = $in
    cd $path

    git fetch --tags
}

export def tags []: string -> list<record<created: datetime, name: string>> {
    let path = $in
    cd $path

    let format = '{ created: "%(creatordate:iso8601-strict)" name: "%(refname:short)" }'
    let result = git for-each-ref --sort=creatordate --format $format refs/tags
        | complete

    if $result.exit_code != 0 {
        error make { msg: ($result.stderr | str trim) }
    }

    $result
        | get stdout | $"([$in])"
        | from nuon
        | upsert created { |row|
            $row.created | into datetime --format %+
        }
}
