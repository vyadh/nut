use std assert
use ../nut/package.nu
use ../nut/project.nu

# [before-each]
def init []: nothing -> record {
    let dir = mktemp --directory

    {
        dir: $dir
    }
}

# [after-each]
def remove []: record -> nothing {
    rm --recursive --force $in.dir
}

# [test]
def "read empty when project file missing" [] {
    cd $in.dir

    let result = project read

    assert equal $result { }
}

# [test]
def "read contents of project file" [] {
    cd $in.dir
    { license: "MIT" } | save "nut.nuon"

    let result = project read

    assert equal $result { license: "MIT" }
}

# [test]
def "has dependency false when project file missing" [] {
    cd $in.dir

    let result = { } | project has dependency ("github.com/example/project" | pkg)

    assert equal $result false
}

# [test]
def "has dependency reflects its presence" [] {
    cd $in.dir
    let data = {
        dependencies: {
            runtime: {
                "github.com/example/present": { version: "0.1.0" }
            }
        }
    }
    $data | save "nut.nuon"

    assert equal ($data | project has dependency ("github.com/example/present" | pkg)) true
    assert equal ($data | project has dependency ("github.com/example/missing" | pkg)) false
}

# [test]
def "has dependency respects fragment" [] {
    cd $in.dir
    let data = {
        dependencies: {
            runtime: {
                "github.com/example/first#component": { version: "0.1.0" }
                "github.com/example/second": { version: "0.1.0" }
            }
        }
    }
    $data | save "nut.nuon"

    assert equal ($data | project has dependency ("github.com/example/first" | pkg)) false
    assert equal ($data | project has dependency ("github.com/example/first#component" | pkg)) true
    assert equal ($data | project has dependency ("github.com/example/second" | pkg)) true
    assert equal ($data | project has dependency ("github.com/example/present#component" | pkg)) false
}

# [test]
def "has dependency searches across categories" [] {
    cd $in.dir
    let data = {
        dependencies: {
            runtime: {
                "github.com/example/runtime": { version: "0.1.0" }
            }
            development: {
                "github.com/example/dev": { version: "0.1.0" }
            }
        }
    }
    $data | save "nut.nuon"

    assert equal ($data | project has dependency ("github.com/example/runtime" | pkg)) true
    assert equal ($data | project has dependency ("github.com/example/dev" | pkg)) true
}

def pkg []: string -> record<host: string, path: string, fragment: string> {
    $"https://($in)" | package resolve "module"
}
