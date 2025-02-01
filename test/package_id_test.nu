use ../nut/package_id.nu
use std assert

# [test]
def "from string when invalid" [] {
    assert equal (catch-error { "invalid" | package_id from string }) ""
    assert equal (catch-error { "1:2" | package_id from string }) ""
    assert equal (catch-error { "1:2:3:4:5" | package_id from string }) ""
}

# [test]
def "to string when git server hosted" [] {
    let id = { scheme: "git", domain: "github.com", path: "vyadh/nut", fragment: "" }
    let str = "git:github.com:vyadh/nut"
    assert equal ($id | package_id to string) $str
}

# [test]
def "from string when git server hosted" [] {
    let id = { scheme: "git", domain: "github.com", path: "vyadh/nut", fragment: "" }
    let str = "git:github.com:vyadh/nut"
    assert equal ($str | package_id from string) $id
}

# [test]
def "to string when git server hosted with fragment" [] {
    let id = { scheme: "git", domain: "github.com", path: "vyadh/nut", fragment: "semver" }
    let str = "git:github.com:vyadh/nut:semver"
    assert equal ($id | package_id to string) $str
}

# [test]
def "to string when a local path" [] {
    let id = { scheme: "git", domain: "", path: "/path/to/vyadh/nut", fragment: "" }
    let str = "git::/path/to/vyadh/nut"
    assert equal ($id | package_id to string) $str
}

# [test]
def "to string when a local path with fragment" [] {
    let id = { scheme: "git", domain: "", path: "path/to/vyadh/nut", fragment: "semver" }
    let str = "git::path/to/vyadh/nut#semver"
    assert equal ($id | package_id to string) $str
}

def catch-error [job: closure]: nothing -> string {
    try {
        do $job
        error make { msg: "no-error" }
    } catch { |error|
        if ($error.msg == "no-error") {
            error make {
                msg: "Expected an error"
                label: {
                    text: "from here"
                    span: (metadata $job).span
                }
            }
        } else {
            $error.msg
        }
    }
}
