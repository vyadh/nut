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

# [test]
def "add dependency to empty project" [] {
    let result = { } | project add dependency "runtime" {
        host: "github.com"
        path: "/example/project"
        fragment: "component"
        version: "1.1.0"
        revision: "abcdef"
    }

    assert equal $result {
        dependencies: {
            runtime: {
                "github.com/example/project#component": {
                    version: "1.1.0"
                    revision: "abcdef"
                }
            }
        }
    }
}

# [test]
def "add dependency to existing project" [] {
    let project = {
        license: "MIT"
        dependencies: {
            runtime: {
                "github.com/example/project": {
                    version: "0.1.0"
                    revision: "01"
                }
            }
            development: {
                "github.com/example/nutest": {
                    version: "1.0.0"
                    revision: "02"
                }
            }
        }
    }

    let result = $project | project add dependency "runtime" {
        host: "gitlab.com"
        path: "/awesome/project"
        fragment: ""
        version: "1.1.0"
        revision: "0123456789"
    }

    assert equal $result {
        license: "MIT"
        dependencies: {
            runtime: {
                "github.com/example/project": {
                    version: "0.1.0"
                    revision: "01"
                 }
                "gitlab.com/awesome/project": {
                    version: "1.1.0"
                    revision: "0123456789"
                }
            }
            development: {
                "github.com/example/nutest": {
                    version: "1.0.0"
                    revision: "02"
                }
            }
        }
    }
}

# [test]
def "write project file with content" [] {
    cd $in.dir
    let data = {
        license: "MIT"
    }

    let result = $data | project write

    assert equal $result $data
    assert equal (open "nut.nuon") { license: "MIT" }
}

# [test]
def "write project overwrites previous" [] {
    cd $in.dir
    "{}" | save "nut.nuon"
    let data = {
        license: "MIT"
    }

    let result = $data | project write

    assert equal $result $data
    assert equal (open "nut.nuon") { license: "MIT" }
}

def pkg []: string -> record<host: string, path: string, fragment: string> {
    $"https://($in)" | package from id
}
