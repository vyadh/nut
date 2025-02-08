use package.nu

const project_file = "nut.nuon"

export def read []: nothing -> record {
    if ($project_file | path exists) {
        open $project_file
    } else {
        { }
    }
}

export def "has dependency" [package: record<host: string, path: string, fragment: string>]: record -> bool {
    let project = $in

    let dependencies = $project
        | get --ignore-errors dependencies | default { }
        | values # We're not concerned about the category of dependency
        | columns

    let id = $package | package id
    $id in $dependencies
}
