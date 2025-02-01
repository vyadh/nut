
# Resolve package information to a canonical form.
export def resolve [
    type: string, version: string
]: string -> record<scheme:string, host:string, path:string, fragment:string, type:string, version:string,> {
    let url = $in | url parse | validate

    $url
        | select scheme host path fragment
        | update host { |it| $it.host | str downcase }
        | update path { |it| $it.path | str replace --regex '\.git$' '' }
        | insert type $type
        | insert version $version
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
