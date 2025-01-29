use std assert
source ../nut/semver.nu

# [test]
def "resolve versions that do not match the spec" [] {
    assert equal ("1" | resolve) []
    assert equal ("1.0" | resolve) []
    assert equal ("1.0.a" | resolve) []
    assert equal ("01.0.0" | resolve) []
    assert equal ("1.0.0+a+b" | resolve) []
    assert equal ("1.0.0-snapshot+a+b" | resolve) []
    assert equal ("1.0.0.0" | resolve) []
    assert equal ("1.0.0-" | resolve) []
    assert equal ("1.0.0+" | resolve) []
    assert equal ("1.0.0-+" | resolve) []
}

# [test]
def "resolve versions that match the spec" [] {
    assert equal ("1.2.3" | resolve) [{ major: 1, minor: 2, patch: 3, prerelease: "", build: "" }]
    assert equal ("1.0.0-pre" | resolve) [{ major: 1, minor: 0, patch: 0, prerelease: "pre", build: "" }]
    assert equal ("1.0.0-pre.123" | resolve) [{ major: 1, minor: 0, patch: 0, prerelease: "pre.123", build: "" }]
    assert equal ("1.0.0-pre+build" | resolve) [{ major: 1, minor: 0, patch: 0, prerelease: "pre", build: "build" }]
    assert equal ("1.0.0-pre+build.123" | resolve) [{ major: 1, minor: 0, patch: 0, prerelease: "pre", build: "build.123" }]
    assert equal ("1.0.0-pre.123+build.456" | resolve) [{ major: 1, minor: 0, patch: 0, prerelease: "pre.123", build: "build.456" }]
}

# [test]
def "compare when equal" [] {
    assert equal (parse-compare "1.2.3" "1.2.3") 0
}

# [test]
def "compare when major difference" [] {
    assert equal (parse-compare "1.0.0" "2.0.0") (-1)
    assert equal (parse-compare "3.0.0" "1.0.0") (2)
}

# [test]
def "compare when minor difference" [] {
    assert equal (parse-compare "0.1.0" "0.3.0") (-2)
    assert equal (parse-compare "0.4.0" "0.1.0") (3)
}

# [test]
def "compare when patch difference" [] {
    assert equal (parse-compare "0.0.2" "0.0.6") (-4)
    assert equal (parse-compare "0.0.7" "0.0.1") (6)
}

# [test]
def "compare pre-release is always less than final" [] {
    assert equal (parse-compare "0.1.0" "0.1.0-alpha") (1)
    assert equal (parse-compare "0.1.0-beta" "0.1.0") (-1)
    assert equal (parse-compare "0.1.1-0" "0.1.1") (-1)
}

# [test]
def "compare pre-release compared numerically" [] {
    assert equal (parse-compare "0.1.0-5" "0.1.0-1") (4)
    assert equal (parse-compare "0.1.0-alpha.1" "0.1.0-alpha.10") (-9)
    assert equal (parse-compare "0.1.0-alpha.8" "0.1.0-alpha.2") (6)
    assert equal (parse-compare "0.1.0-alpha.1.4" "0.1.0-alpha.1.1") (3)
    assert equal (parse-compare "0.1.0-alpha.1.2" "0.1.0-alpha.1.7") (-5)
    assert equal (parse-compare "0.1.0-alpha.1.1.3" "0.1.0-alpha.1.1.1") (2)
}

# [test]
def "compare pre-release non-equal parts" [] {
    assert equal (parse-compare "0.1.0-1.2" "0.1.0-1") (1)
    assert equal (parse-compare "0.1.0-1" "0.1.0-1.2") (-1)
    assert equal (parse-compare "0.1.0-1" "0.1.0-1.2.3") (-1)
}

# [test]
def "compare pre-release by spec rule" [] {
    assert equal (parse-compare "0.1.0-alpha" "0.1.0-alpha.1") (-1)
    assert equal (parse-compare "0.1.0-alpha.1" "0.1.0-alpha.beta") (-1)
    assert equal (parse-compare "0.1.0-alpha.beta" "0.1.0-beta") (-1)
    assert equal (parse-compare "0.1.0-beta" "0.1.0-beta.2") (-1)
    assert equal (parse-compare "0.1.0-beta.2" "0.1.0-beta.11") (-9)
    assert equal (parse-compare "0.1.0-beta.11" "0.1.0-rc.1") (-1)
    assert equal (parse-compare "0.1.0-rc.1" "0.1.0") (-1)
}

# [test]
def "sorted takes into account degree of difference" [] {
    let versions = [
        "0.1.50"
        "0.1.20"
        "0.1.3"
        "0.1.10"
        "0.1.100"
        "0.1.5"
        "0.1.1"
    ]

    assert equal ($versions | sorted) [
        "0.1.1"
        "0.1.3"
        "0.1.5"
        "0.1.10"
        "0.1.20"
        "0.1.50"
        "0.1.100"
    ]
}

# [test]
def "sorted by spec example" [] {
    let versions = [
        "0.1.0"
        "0.1.0-rc.1"
        "0.1.0-beta.11"
        "0.1.0-beta.2"
        "0.1.0-beta"
        "0.1.0-alpha.beta"
        "0.1.0-alpha.1"
        "0.1.0-alpha"
    ]

    assert equal ($versions | sorted) [
        "0.1.0-alpha"
        "0.1.0-alpha.1"
        "0.1.0-alpha.beta"
        "0.1.0-beta"
        "0.1.0-beta.2"
        "0.1.0-beta.11"
        "0.1.0-rc.1"
        "0.1.0"
    ]
}

def parse-compare [a: string, b: string]: nothing -> int {
    let a = $a | resolve | first
    let b = $b | resolve | first
    compare $a $b
}
