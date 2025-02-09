use package.nu
use paths.nu

def collate []: record -> table<name: string, module: string> {
    let project = $in
    $project
        | dependencies
        | insert pkg { $in.id | package from id }
        | insert name { $in.pkg.path | to name }
        | insert module { to module $in.name }
        | select name module
}

def dependencies []: record -> table<id: string, revision: string> {
    let project = $in
    $project
        | child dependencies
        | flatten
        | transpose id data
        | insert revision { $in.data.revision }
        | reject data
}

def child [name: string]: record -> record {
    let node = $in
    $node | get --ignore-errors $name | default { }
}

def "to name" []: string -> string {
    # todo ever be empty?
    # todo what about when it's a file?
    let path = $in
    $path | path basename
}

def "to module" [name: string]: record<pkg: record, revision: string> -> string {
    let path = { ...$in.pkg, revision: $in.revision } | paths revision-dir
    $"($path)/($name)"
}
