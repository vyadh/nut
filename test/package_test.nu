use ../nut/package.nu
use errors.nu catch-error
use std assert

# [test]
def "from id with normal data" [] {
    let result = "https://example.com/path/repo" | package from id

    assert equal $result {
        scheme: "https"
        host: "example.com"
        path: "/path/repo"
        fragment: ""
    }
}

# [test]
def "from id always results in lower case domain only" [] {
    let result = "https://NuCo.com/path/MyRepo" | package from id

    assert equal ($result | select host path) {
        host: "nuco.com"
        path: "/path/MyRepo"
    }
}

# [test]
def "from id removes git postfix" [] {
    let result = "https://example.com/path/repo.git" | package from id

    assert equal ($result | select path) {
        path: "/path/repo"
    }
}

# [test]
def "from id defaults to https scheme" [] {
    assert equal ("example.com/repo" | package from id | get scheme) "https"
}

# [test]
def "from id validates scheme" [] {
    assert equal ("https://example.com/repo" | package from id | get scheme) "https"
    assert equal ("file://example.com/repo" | package from id | get scheme) "file"
    assert equal (catch-error { "http://example.com/repo" | package from id }) "Unsupported scheme: http"
}

# [test]
def "from id validates when unsupported urls" [] {
    assert equal (catch-error { "https://example.com" | package from id }) "Empty path is unsupported"
    assert equal (catch-error { "https://user:pass@example.com/repo" | package from id }) "Credentials are unsupported"
    assert equal (catch-error { "https://example.com:123/repo" | package from id }) "Port is unsupported"

    # todo Might want to validate this
    assert equal ("https://invalid_domain/repo" | package from id | get host) "invalid_domain"
}

# [test]
def "from id with fragment" [] {
    let result = "https://github.com/example/repo#util"
        | package from id
        | get fragment

    assert equal $result "util"
}

# [test]
def "to id from package data" [] {
    let package = { host: "example.com", path: "/path/repo", fragment: "" }

    let result = $package | package to id

    assert equal $result "example.com/path/repo"
}

# [test]
def "to id from package data with fragment" [] {
    let package = { host: "example.com", path: "/path/repo", fragment: "util" }

    let result = $package | package to id

    assert equal $result "example.com/path/repo#util"
}
