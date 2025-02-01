
# URNs
# - git:github.com:vyadh/nut
# - git:github.com:vyadh/nut:semver
# - git:~user/dev:path/to/package

# URLs:
# - https://github.com/vyadh/nut.git

# Paths:
# - /home/user/path/to/package
# - file:///path/to/repo/

export def "to string" []: record<scheme: string, domain: string, path: string, fragment: string> -> string {
    let id = $in
    if ($id.fragment | is-empty) {
        $"($id.scheme):($id.domain):($id.path)"
    } else {
        $"($id.scheme):($id.domain):($id.path):($id.fragment)"
    }
}

export def "from string" []: string -> record<scheme: string, domain: string, path: string, fragment: string> {
    { scheme: "git", domain: "github.com", path: "vyadh/nut", fragment: "semver" }
}

# Convert our internal representation to a Git URL or path.
export def "to git" []: record<scheme: string, domain: string, path: string, fragment: string> -> string {
    # url or file
    ""
}

# Convert a Git URL or path to our internal representation.
export def "from git" []: string -> record<scheme: string, domain: string, path: string, fragment: string> {
    {
        scheme: "git",
        domain: "",
        path: ""
        fragment: ""
    }
}

# todo not sure we need below?

#def "to url" []: record<scheme: string, domain: string, path: string, fragment: string> -> string {
#    error make { msg: "Not implemented" }
#}
#
#def "from url" []: string -> record<scheme: string, domain: string, path: string, fragment: string> {
#    error make { msg: "Not implemented" }
#}
#
#def "to path" []: record<scheme: string, domain: string, path: string, fragment: string> -> string {
#    error make { msg: "Not implemented" }
#}
#
#def "from path" []: string -> record<scheme: string, domain: string, path: string, fragment: string> {
#    error make { msg: "Not implemented" }
#}
