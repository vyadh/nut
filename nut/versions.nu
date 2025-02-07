use semver.nu

export def resolved []: table<tag: string, commit: string> -> table<tag: string, commit: string, version: string, semver: record> {
    let tags = $in

    $tags
        | insert version { $in.tag | str trim --left --char "v" }
        | where { $in.version | semver valid }
        | insert semver { $in.version | semver resolve }
}

export def latest []: table<tag: string, commit: string, version: string, semver: record> -> record<tag: string, commit: string, version: string, semver: record> {
    let versions = $in

    if ($versions | is-empty) {
        error make { msg: "No versions found" }
    }

    $versions
        | sort-by --reverse --custom { |a, b|
            (semver compare ($a | get semver) ($b | get semver)) < 0
        }
        | first
}
