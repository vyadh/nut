source ../nut/overlays.nu
use std assert

# [before-each]
def init []: nothing -> record {
    let dir = mktemp --directory

    {
        temp: $dir
    }
}

# [after-each]
def remove []: record -> nothing {
    rm --recursive --force $in.temp
}

# [test]
def "collate when no dependencies" [] {
    let project = { }

    let result = $project | collate

    assert equal $result []
}

# [test]
def "collate when dependencies present" [] {
    let temp = $in.temp

    let project = {
        dependencies: {
            runtime: {
                "github.com/org/project1": {
                    version: "1.1.1"
                    revision: "1234"
                }
            }
            development: {
                "github.com/org/project2": {
                    version: "2.2.2"
                    revision: "4321"
                }
            }
        }
    }

    with-env { XDG_DATA_HOME: $temp } {
        let result = $project | collate

        assert equal ($result | length) 2
        assert equal ($result | get 0.name) "project1"
        assert equal ($result | get 1.name) "project2"
        assert (($result | get 0.module) like "/_org_project1-[0-9a-f]{32}/1234/project1$")
        assert (($result | get 1.module) like "/_org_project2-[0-9a-f]{32}/4321/project2$")
    }
}
