use ../nut/package_id.nu
use std assert

# [test]
def "resolve id with regular id is unchanged" [] {
    assert equal ("example.com/path/repo" | package_id resolve) "example.com/path/repo"
}

# [test]
def "resolve id removes schema prefix of those we support" [] {
    assert equal ("https://example.com/path/repo" | package_id resolve) "example.com/path/repo"
    assert equal ("http://example.com/path/repo" | package_id resolve) "example.com/path/repo"
}

# [test]
def "resolve id always results in lower case" [] {
    assert equal ("NuCo.com/path/MyRepo" | package_id resolve) "nuco.com/path/myrepo"
}

# [test]
def "resolve id removes git postfix" [] {
    assert equal ("example.com/path/repo.git" | package_id resolve) "example.com/path/repo"
}

# [test]
def "validate id with remote repos" [] {
    let id = "example.com/some-path/new_repo.1"
    assert equal ($id | package_id validate) $id
}

# [test]
def "validate id with path-based repos" [] {
    assert equal ("some/relative/path" | package_id validate) "some/relative/path"
    assert equal ("/some/absolute/path" | package_id validate) "/some/absolute/path"
    assert equal ("~/dev/repo" | package_id validate) "~/dev/repo"
}

# [test]
def "validate id throws error when invalid" [] {
    assert equal (catch-error { "example.com" | package_id validate }) "Invalid package id: example.com"
    assert equal (catch-error { "user:pass@example.com/[a-z]" | package_id validate }) "Invalid package id: user:pass@example.com/[a-z]"
    assert equal (catch-error { "example.com:123" | package_id validate }) "Invalid package id: example.com:123"
}

# [test]
def "parse when host and path" [] {
    let str = "github.com/vyadh/nut"
    let id = { name: "github.com/vyadh/nut", fragment: "" }
    assert equal ($str | package_id extract) $id
}

# [test]
def "parse with fragment" [] {
    let str = "github.com/vyadh/nut#semver"
    let id = { name: "github.com/vyadh/nut", fragment: "semver" }
    assert equal ($str | package_id extract) $id
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
