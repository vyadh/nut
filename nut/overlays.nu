use package.nu
use paths.nu

export def set-active []: record -> nothing {
    let command = $in | command
    # todo add new overlay for project activity?
    # todo change prompt to indicate active project
    let launch = $"$env.config.show_banner = false; ($command)"
    print "Activating project..."
    nu --execute $launch
    print "Exited project"
}

def command []: record -> string {
    let project = $in
    $project
        | collate
        | each {
            let name = $in.name
            let module = $in.module
            $'overlay use "($module)"; use ($name)'
        }
        | str join "; "
}

def collate []: record -> table<name: string, module: string> {
    let project = $in
    $project
        | dependencies
        | insert pkg { $in.id | package from id }
        | insert name { to name }
        | insert module { to module }
        | select name module
}

def dependencies []: record -> table<id: string, revision: string> {
    let project = $in
    $project
        | child dependencies
        | flatten
        | transpose id data
        | insert revision { $in.data.revision }
        | select id revision
}

def child [name: string]: record -> record {
    let node = $in
    $node | get --ignore-errors $name | default { }
}

# todo detect conflicts
# todo path ever be empty?
# todo need to escape this, or do we already validate with regex?
def "to name" []: record<pkg: record> -> string {
    let pkg = $in.pkg
    let basename = $pkg.path | path basename

    if ($pkg.fragment | is-not-empty) {
        # some/path/module.nu -> module
        $pkg.fragment | path basename | path parse | get stem
    } else {
        $basename
    }
}

# todo detect conflicts
# todo path ever be empty?
# todo need to escape this, or do we already validate with regex?
def "to module" []: record<pkg: record, revision: string> -> string {
    let pkg = $in.pkg
    let revision = $in.revision
    let basename = $pkg.path | path basename
    let repo_path = { ...$pkg, revision: $revision } | paths revision-dir

    if ($pkg.fragment | is-not-empty) {
        # `overlay use` will name as file without extension
        $"($repo_path)/($pkg.fragment)"
    } else {
        $"($repo_path)/($basename)"
    }
}
