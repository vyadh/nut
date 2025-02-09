use package.nu

const project_file = "nut.nuon"

export def read []: nothing -> record {
    if ($project_file | path exists) {
        open $project_file
    } else {
        { }
    }
}

export def write []: record -> record {
    let project = $in
    let nuon = $project | to nuon --indent 2
    $nuon | save --force $project_file
    $project
}

export def "has dependency" [package: record<host: string, path: string, fragment: string>]: record -> bool {
    let project = $in

    let all_dependencies = $project
        | child dependencies
        | values # We're not concerned about the category of dependency
        | columns

    let id = $package | package to id
    $id in $all_dependencies
}

export def "add dependency" [
    category: string
    package: record<host: string, path: string, fragment: string, version: string>
]: record -> record {

    let project = $in
    let dependencies = $project | child dependencies
    let existing_dependencies = $dependencies | child $category
    let dependency = {
        ($package | package to id): {
            version: $package.version
            revision: $package.revision
        }
    }

    {
        ...($project | reject --ignore-errors dependencies)
        dependencies: {
            ...($dependencies | reject --ignore-errors $category)
            $category: {
                ...$existing_dependencies
                ...$dependency
            }
        }
    }
}

def child [name: string]: record -> record {
    let node = $in
    $node | get --ignore-errors $name | default { }
}
