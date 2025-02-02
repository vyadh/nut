
export def config-dir [] {
    let dir = $env.XDG_CONFIG_HOME?
        | default ($env.HOME | path join ".config")
        | path join "nut"

    mkdir $dir
    $dir
}

export def data-dir [] {
    let dir = $env.XDG_DATA_HOME?
        | default ($env.HOME | path join ".local" | path join "share")
        | path join "nut"

    mkdir $dir
    $dir
}

export def repos-dir [] {
    let dir = data-dir | path join "repos"
    mkdir $dir
    $dir
}
