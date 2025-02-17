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

export def "find dependencies" []: record -> list<record<id: string, category: string, version: string, revision: string>> {
    let project = $in
    let dependencies = $project | child dependencies

    $dependencies
        | columns
        | each { |category_name|
            $dependencies
                | child $category_name
                | items { |id, dependency|
                    {
                        id: $id
                        category: $category_name
                        version: $dependency.version
                        revision: $dependency.revision
                    }
                }
        }
        | flatten
}

export def "find dependency" [package: record<host: string, path: string, fragment: string>]: record -> any {
    let project = $in
    let id = $package | package to id
    let dependencies = $project
        | find dependencies
        | filter { $in.id == $id }

    if ($dependencies | is-empty) {
        null
    } else {
        $dependencies | first
    }
}

export def "upsert dependency" [
    category: string
    package: record<host: string, path: string, fragment: string, version: string>
]: record -> record {

    let project = $in
    let id = $package | package to id
    let dependencies = $project | child dependencies
    let other_categories = $dependencies | reject --ignore-errors $category
    let other_dependencies = $dependencies | child $category | reject --ignore-errors $id
    let other_project_data = $project | reject --ignore-errors dependencies

    let dependency = {
        $id: {
            version: $package.version
            revision: $package.revision
        }
    }

    {
        ...$other_project_data
        dependencies: {
            ...$other_categories
            $category: {
                ...$other_dependencies
                ...$dependency
            }
        }
    }
}

export def "remove dependency" [
    package: record<host: string, path: string, fragment: string>
]: record -> record {

    let project = $in
    let id = $package | package to id
    let dependencies = $project | child dependencies
    let existing = $project | find dependency $package
    if $existing == null {
        error make { msg: $"Package doesn't exist in project: ($id)" }
    }

    let category = $existing.category

    {
        ...($project | reject --ignore-errors dependencies)
        dependencies: {
            $category: {
                ...($dependencies | child $category | reject --ignore-errors $id)
            }
        }
    }
}

def child [name: string]: record -> record {
    let node = $in
    $node | get --ignore-errors $name | default { }
}
