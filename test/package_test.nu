use ../nut/package.nu
use errors.nu catch-error
use std assert

# [test]
def "resolve id with normal data" [] {
    let result = "https://example.com/path/repo" | package resolve "module" "v0.1.0"

    assert equal $result {
        scheme: "https"
        host: "example.com"
        path: "/path/repo"
        fragment: ""
        type: "module"
        version: "v0.1.0"
    }
}

# [test]
def "resolve id always results in lower case domain only" [] {
    let result = "https://NuCo.com/path/MyRepo" | package resolve "" ""

    assert equal ($result | select host path) {
        host: "nuco.com"
        path: "/path/MyRepo"
    }
}

# [test]
def "resolve id removes git postfix" [] {
    let result = "https://example.com/path/repo.git" | package resolve "" ""

    assert equal ($result | select path) {
        path: "/path/repo"
    }
}

# [test]
def "resolve validates scheme" [] {
    assert equal ("https://example.com/repo" | package resolve "" "" | get scheme) "https"
    assert equal ("file://example.com/repo" | package resolve "" "" | get scheme) "file"
    assert equal (catch-error { "http://example.com/repo" | package resolve "" "" }) "Unsupported scheme: http"
}

# [test]
def "resolve validates when unsupported urls" [] {
    assert equal (catch-error { "https://example.com" | package resolve "" "" }) "Empty path is unsupported"
    assert equal (catch-error { "https://user:pass@example.com/repo" | package resolve "" "" }) "Credentials are unsupported"
    assert equal (catch-error { "https://example.com:123/repo" | package resolve "" "" }) "Port is unsupported"

    # todo Might want to validate this
    assert equal ("https://invalid_domain/repo" | package resolve "" "" | get host) "invalid_domain"
}

# [test]
def "parse with fragment" [] {
    let result = "https://github.com/vyadh/nut#semver" | package resolve "" "" | get fragment

    assert equal $result "semver"
}
