# Naming conventions for the command in this file:
# - dir: an absolute path to a directory
# - path: a relative path to a director

export def config-dir []: nothing -> path {
    let dir = $env.XDG_CONFIG_HOME?
        | default ($env.HOME | path join ".config")
        | path join "nut"

    mkdir $dir
    $dir
}

export def data-dir []: nothing -> path {
    let dir = $env.XDG_DATA_HOME?
        | default ($env.HOME | path join ".local" | path join "share")
        | path join "nut"

    mkdir $dir
    $dir
}

export def clones-dir []: nothing -> path {
    let dir = data-dir | path join "clones"
    mkdir $dir
    $dir
}

export def revisions-dir []: nothing -> path {
    let dir = data-dir | path join "revisions"
    mkdir $dir
    $dir
}

export def clone-dir []: record<host: string, path: string> -> path {
    let pkg = $in
    clones-dir | path join ($pkg | package-path)
}

export def revision-dir []: record<host: string, path: string, revision: string> -> path {
    let pkg = $in

    revisions-dir
        | path join ($pkg | package-path)
        | path join $pkg.revision
}

def package-path []: record<host: string, path: string> -> path {
    let pkg = $in

    let unsafe_chars = '[^a-zA-Z0-9_-]'
    let escaped = $in.path | str replace --all --regex $unsafe_chars "_"

    let slug = $"($pkg.host)/($pkg.path)"
    # MD5 is good enough for this, particularly as we include the path anyway
    let hash = $slug | hash md5

    [ $escaped, $hash ] | str join "-"
}
