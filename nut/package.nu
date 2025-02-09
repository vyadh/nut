
const default_prefix = "https://"

export def "from id" []: string -> record<host: string, path: string, fragment: string> {
    $in
        | with-scheme
        | url parse
        | validate
        | select scheme host path fragment
        | update host { |it| $it.host | str downcase }
        | update path { |it| $it.path | str replace --regex '\.git$' '' }
}

def with-scheme []: string -> string {
    let id = $in
    if not ($id like "[a-z]+://.+") {
        $"($default_prefix)($id)"
    } else {
        $id
    }
}

def validate []: record -> record {
    let url = $in
    if ($url.scheme not-in ["https", "file"]) {
        error make { msg: $"Unsupported scheme: ($url.scheme)" }
    }
    if ($url.path == "/") {
        error make { msg: $"Empty path is unsupported" }
    }
    if ($url.username != "" or $url.password != "") {
        error make { msg: $"Credentials are unsupported" }
    }
    if ($url.port != "") {
        error make { msg: $"Port is unsupported" }
    }
    $url
}

export def "to id" []: record<host: string, path: string, fragment: string> -> string {
    let pkg = $in
    if ($pkg.fragment | is-empty) {
        $"($pkg.host)($pkg.path)"
    } else {
        $"($pkg.host)($pkg.path)#($pkg.fragment)"
    }
}
