use errors.nu catch-error
use std assert
use ../nut/versions.nu

# [test]
def "resolve should return empty for no valid versions" [] {
    let tags = [
        { tag: "0.a.0", commit: "01" }
        { tag: "v.0.0", commit: "02" }
    ]

    let result = $tags | versions resolved

    assert equal $result []
}

# [test]
def "resolve should filter valid versions with specific column" [] {
    let tags = [
        { tag: "1.0.1", commit: "01" }
        { tag: "v1.0.2", commit: "02" }
        { tag: "a.0.0", commit: "0A" }
        { tag: "v0.b.0", commit: "0B" }
    ]

    let result = $tags | versions resolved | select tag commit version

    assert equal $result [
        { tag: "1.0.1", commit: "01", version: "1.0.1" }
        { tag: "v1.0.2", commit: "02", version: "1.0.2" }
    ]
}

# [test]
def "resolve adds parsed semver" [] {
    let tags = [
        { tag: "1.0.1", commit: "01" }
        { tag: "v0.1.2", commit: "02" }
        { tag: "v1.0.3-snapshot+build", commit: "03" }
    ]

    let result = $tags | versions resolved

    assert equal $result [
        [tag, commit, version, semver];
        ["1.0.1", "01", "1.0.1", { major: 1, minor: 0, patch: 1, prerelease: "", build: "" }]
        ["v0.1.2", "02", "0.1.2", { major: 0, minor: 1, patch: 2, prerelease: "", build: "" }]
        ["v1.0.3-snapshot+build", "03", "1.0.3-snapshot+build", { major: 1, minor: 0, patch: 3, prerelease: "snapshot", build: "build" }]
    ]
}

# [test]
def "latest for empty table throws error" [] {
    let data = []

    let result = catch-error {
        $data | versions latest
    }

    assert equal $result "No versions found"
}

# [test]
def "latest calculated by semver" [] {
    let data = [
        { tag: "v1.0.0", commit: "02" }
        { tag: "v1.1.1", commit: "04" }
        { tag: "v1.1.1-snapshot", commit: "05" }
        { tag: "v1.1.0", commit: "03" }
        { tag: "0.1.0", commit: "01" }
    ]

    let result = $data | versions resolved | versions latest

    assert equal $result {
        tag: "v1.1.1"
        commit: "04"
        version: "1.1.1"
        semver: { major: 1, minor: 1, patch: 1, prerelease: "", build: "" }
    }
}
