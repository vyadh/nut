use std assert
use errors.nu catch-error
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

# [test]
def "find dependencies when none" [] {
    let result = { } | project find dependencies

    assert equal $result []
}

# [test]
def "find dependencies from multiple categories" [] {
    let data = {
        dependencies: {
            runtime: {
                "github.com/example/one": { version: "0.1.0", revision: "01" }
            }
            development: {
                "github.com/example/two#component": { version: "0.2.0", revision: "02" }
            }
        }
    }

    let result = $data | project find dependencies

    assert equal $result [
        {
            id: "github.com/example/one"
            category: "runtime"
            version: "0.1.0"
            revision: "01"
        }
        {
            id: "github.com/example/two#component"
            category: "development"
            version: "0.2.0"
            revision: "02"
        }
    ]
}

# [test]
def "find dependency when project file missing" [] {
    let result = { } | project find dependency ("github.com/example/project" | pkg)

    assert equal $result null
}

# [test]
def "find dependency when exists" [] {
    let data = {
        dependencies: {
            runtime: {
                "github.com/example/one": { version: "0.1.0", revision: "01" }
            }
            development: {
                "github.com/example/two": { version: "0.2.0", revision: "02" }
            }
        }
    }

    assert equal ($data | project find dependency ("github.com/example/one" | pkg)) {
        id: "github.com/example/one"
        category: "runtime"
        version: "0.1.0"
        revision: "01"
    }

    assert equal ($data | project find dependency ("github.com/example/two" | pkg)) {
        id: "github.com/example/two"
        category: "development"
        version: "0.2.0"
        revision: "02"
    }
}

# [test]
def "find dependency respects fragment" [] {
    let data = {
        dependencies: {
            runtime: {
                "github.com/example/first#component": { version: "0.1.0", revision: "1" }
                "github.com/example/second": { version: "0.1.0", revision: "1" }
            }
        }
    }

    assert (($data | project find dependency ("github.com/example/first" | pkg)) == null)
    assert (($data | project find dependency ("github.com/example/first#component" | pkg)) != null)
    assert (($data | project find dependency ("github.com/example/second" | pkg)) != null)
    assert (($data | project find dependency ("github.com/example/present#component" | pkg)) == null)
}

# [test]
def "upsert dependency with fragment to empty project" [] {
    let result = { } | project upsert dependency "runtime" {
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
def "upsert dependency to existing project" [] {
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

    let result = $project | project upsert dependency "runtime" {
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
def "upsert existing dependency" [] {
    let project = {
        license: "MIT"
        dependencies: {
            runtime: {
                "github.com/example/project": {
                    version: "0.1.0"
                    revision: "01"
                }
            }
        }
    }

    let result = $project | project upsert dependency "runtime" {
        host: "github.com"
        path: "/example/project"
        fragment: ""
        version: "0.2.0"
        revision: "02"
    }

    assert equal $result {
        license: "MIT"
        dependencies: {
            runtime: {
                "github.com/example/project": {
                    version: "0.2.0"
                    revision: "02"
                 }
            }
        }
    }
}

# [test]
def "remove package that was not added" [] {
    let project = { }
    let pkg = {
        host: "github.com"
        path: "/example/project"
        fragment: ""
    }

    let error = catch-error {
        $project | project remove dependency $pkg
    }

    assert equal $error "Package doesn't exist in project: github.com/example/project"
}

# [test]
def "remove package that was previously added" [] {
    let project = {
        dependencies: {
            runtime: {
                "github.com/example/project": {
                    version: "0.1.0"
                    revision: "01"
                }
                "github.com/example/project2": {
                    version: "0.1.0"
                    revision: "01"
                }
            }
            development: {
                "github.com/example/project": {
                    version: "1.0.0"
                    revision: "02"
                }
            }
        }
    }

    let pkg = {
        host: "github.com"
        path: "/example/project"
        fragment: ""
    }

    let result = $project | project remove dependency $pkg
    #}

    assert equal $result {
        dependencies: {
            runtime: {
                "github.com/example/project2": {
                    version: "0.1.0"
                    revision: "01"
                }
            }
        }
    }
}

def pkg []: string -> record<host: string, path: string, fragment: string> {
    $"https://($in)" | package from id
}
