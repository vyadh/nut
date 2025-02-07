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

export def locate [version: string]: table<tag: string, version: string> -> record<tag: string, commit: string, version: string, semver: record> {
    let tags = $in

    let exact_match = $tags | where { $in.tag == $version }
    if not ($exact_match | is-empty) {
        return ($exact_match | first)
    }

    let versions = $tags | where { $in.version == $version or $in.version == $"v($version)" }
    if ($versions | is-empty) {
        error make { msg: $"Version not found: ($version)" }
    } else if ($versions | length) > 1 {
        error make { msg: $"Multiple versions found for ($version): ($versions | str join ',')" }
    } else {
        $versions | first
    }
}
