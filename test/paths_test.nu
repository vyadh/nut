use ../nut/paths.nu
use std assert

# [before-each]
def init []: nothing -> record {
    let temp = mktemp --directory
    {
        temp: $temp
    }
}

# [after-each]
def remove []: nothing -> nothing {
    rm --recursive --force $in.temp
}

# [test]
def "config-dir is overridable" [] {
    with-env { XDG_CONFIG_HOME: $in.temp } {
        let dir = paths config-dir

        assert equal $dir (
            $in.temp | path join "nut"
        )
    }
}

# [test]
def "data-dir is overridable" [] {
    with-env { XDG_DATA_HOME: $in.temp } {
        let dir = paths data-dir

        assert equal $dir (
            $in.temp | path join "nut"
        )
    }
}

# [test]
def "repo-dir is overridable" [] {
    with-env { XDG_DATA_HOME: $in.temp } {
        let dir = paths repos-dir

        assert equal $dir (
            $in.temp | path join "nut" | path join "repos"
        )
    }
}

# [test]
def "version-dir is overridable" [] {
    with-env { XDG_DATA_HOME: $in.temp } {
        let dir = paths versions-dir

        assert equal $dir (
            $in.temp | path join "nut" | path join "versions"
        )
    }
}
