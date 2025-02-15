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

export def "find category" [package: record<host: string, path: string, fragment: string>]: record -> any {
    let project = $in
    let id = $package | package to id

    for category in ["runtime", "development"] {
        let dependencies = $project | child dependencies
        let dependency = $dependencies | child $category | get --ignore-errors $id
        if $dependency != null {
            return $category
        }
    }

    null
}

export def "has dependency" [package: record<host: string, path: string, fragment: string>]: record -> bool {
    ($in | find category $package) != null
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

export def "remove dependency" [
    package: record<host: string, path: string, fragment: string>
]: record -> record {

    let project = $in
    let dependencies = $project | child dependencies
    let id = $package | package to id

    {
        ...($project | reject --ignore-errors dependencies)
        dependencies: {
            runtime: {
                ...($dependencies | child runtime | reject --ignore-errors $id)
            }
            development: {
                ...($dependencies | child development | reject --ignore-errors $id)
            }
        }
    }
}

def child [name: string]: record -> record {
    let node = $in
    $node | get --ignore-errors $name | default { }
}
