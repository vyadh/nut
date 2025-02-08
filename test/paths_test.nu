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
def remove []: record -> nothing {
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
def "clones-dir is overridable" [] {
    with-env { XDG_DATA_HOME: $in.temp } {
        let dir = paths clones-dir

        assert equal $dir (
            $in.temp | path join "nut" | path join "clones"
        )
    }
}

# [test]
def "revisions-dir is overridable" [] {
    with-env { XDG_DATA_HOME: $in.temp } {
        let dir = paths revisions-dir

        assert equal $dir (
            $in.temp | path join "nut" | path join "revisions"
        )
    }
}

# [test]
def "clone-dir includes safe characters only and hash of original" [] {
    let pkg = {
        host: "example.com"
        path: "../some\\repo'\""
    }

    with-env { XDG_DATA_HOME: $in.temp } {
        let result = $pkg | paths clone-dir

        assert equal $result $"(paths clones-dir)/___some_repo__-($pkg | hash)"
    }
}

# [test]
def "revision-dir includes hash of host and path" [] {
    let pkg = {
        host: "example.com"
        path: "repo"
        commit: "1234567890"
    }

    with-env { XDG_DATA_HOME: $in.temp } {
        let result = $pkg | paths revision-dir

        assert equal $result $"(paths revisions-dir)/repo-($pkg | hash)/1234567890"
    }
}

def hash []: record<host: string, path: string> -> string {
    $"($in.host)/($in.path)" | hash md5
}
