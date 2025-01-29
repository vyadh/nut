# An implementation of the Semantic Versioning 2.0.0 specification.
# https://semver.org
#
# Components:
#   major, minor, patch, pre-release, build
#

# Suggested regex pattern from the spec
# TODO add optional 'v' prefix here?
const pattern = '^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'

export def sorted []: list<string> -> list<string> {
    $in
        | each { |version|
            $version
                | resolve
                | each { |row| { original: $version, resolved: $row } }
        }
        | flatten
        | sort-by --custom { |a, b|
            (compare ($a | get resolved) ($b | get resolved)) < 0
        }
        | each { |row| $row.original }
}

# Returns a one-element table of the components if the version matches the spec.
# Otherwise, returns an empty table.
def resolve []: string -> table<major: int, minor: int, patch: int, prerelease: string, build> {
    let result = $in | parse --regex $pattern

    if ($result | is-empty) {
        []
    } else {
        let row = $result | first
        [{
            major: ($row.major | into int)
            minor: ($row.minor | into int)
            patch: ($row.patch | into int)
            prerelease: $row.prerelease
            build: $row.buildmetadata
        }]
    }
}

# Precedence:
#   major > minor > patch
#   pre-release existence lower than non-pre-release
#   pre-release version rules
#   no precedence: build
def compare [
    a: record<major: int, minor: int, patch: int, prerelease: string, build>
    b: record<major: int, minor: int, patch: int, prerelease: string, build>
]: nothing -> int {

    if $a.major != $b.major {
        $a.major - $b.major
    } else if $a.minor != $b.minor {
        $a.minor - $b.minor
    } else if $a.patch != $b.patch {
        $a.patch - $b.patch
    } else if $a.prerelease != $b.prerelease {
        compare-prerelease $a.prerelease $b.prerelease
    } else {
        0
    }
}

def compare-prerelease [a: string, b: string]: nothing -> int {
    if ($a | is-empty) and not ($b | is-empty) {
        1
    } else if not ($a | is-empty) and ($b | is-empty) {
        -1
    } else {
        compare-prerelease-parts ($a | split row ".") ($b | split row ".")
    }
}

def compare-prerelease-parts [as: list<string>, bs: list<string>]: nothing -> int {
    let len = [($as | length), ($bs | length)] | math max

    # Maximum this will compare is one plus the length of the shorter list
    for i in 0..($len - 1) {
        let a = $as | get --ignore-errors $i | default null
        let b = $bs | get --ignore-errors $i | default null

        if ($a != null and $b == null) {
            return 1
        } else if ($a == null and $b != null) {
            return (-1)
        } else if not ($a | is-int) and ($b | is-int) {
            return 1
        } else if ($a | is-int) and not ($b | is-int) {
            return (-1)
        } else if ($a | is-int) and ($b | is-int) and ($a != $b) {
            return (($a | into int) - ($b | into int))
        } else if $a != $b {
            return (compare-string $a $b)
        }
    }

    0
}

def is-int []: string -> bool {
    try {
        $in | into int
        true
    } catch {
        false
    }
}

def compare-string [a: string, b: string]: nothing -> int {
    if ([$a, $b] | sort | first) == $b {
        1
    } else {
        (-1)
    }
}
