
# Ids:
# - github.com/vyadh/nut
# - github.com/vyadh/nut#semver
# - /~user/dev/path/to/package

# Git URLs:
# - https://github.com/vyadh/nut.git

# Paths:
# - /home/user/path/to/package
# - file:///path/to/repo/


# Resolve the name to a canonical package id. This includes removing the scheme part of the URL,
# removing `/git` suffixes and ensuring the path satisfies certain validation.
export def "resolve" []: string -> string {
    $in
        | str replace --regex '^(https?://)?' ''
        | str replace --regex '\.git$' ''
        | str downcase

}

# Enforce the rules for a package name to catch accidental errors and prevent injection attacks.
export def "validate" []: string -> string {
    let id = $in
    let regex = '^([~/a-z0-9.-]+)(\/[^\s#]*)(#[^\s]*)?$'
    if ($id like $regex) {
        return $id
    } else {
        error make { msg: $"Invalid package id: ($id)" }
    }
}

# Parse the name and optional fragment
export def "extract" []: string -> record<name: string, fragment: string> {
    $in
        | parse --regex '^(?P<name>[^#]+)(?:#(?P<fragment>.*))?$'
        | first
}
