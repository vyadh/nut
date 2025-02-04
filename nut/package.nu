
# Resolve package information to a canonical form.
export def resolve [
    type: string, version?: string
]: string -> record<scheme: string, host: string, path: string, fragment: string, type: string, version: string> {
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

# todo perhaps in a paths.nu?
export def repo-path []: record<host: string, path: string> -> string {
    let unsafe_chars = '[^a-zA-Z0-9_-]'
    let escaped = $in.path | str replace --all --regex $unsafe_chars "_"

    let slug = $"($in.host)/($in.path)"
    let hash = $slug | hash md5 # MD5 is good enough for this given we include the path anyway

    [ $escaped, $hash ] | str join "-"
}

export def commit-path []: record<host: string, path: string, commit: string> -> string {
    let pkg = $in
    let repo_path = $pkg | repo-path
    $repo_path | path join $pkg.commit
}
