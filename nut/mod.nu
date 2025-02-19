
# TODO This top-level module is a PoC.
# TODO It is here to explore what is required from the supporting modules.

# Needed operations:
# - ☑️ add a package to the project
# - ☑️ add required overlays
# - ☑️ support sub-modules
# - ☑️ remove a package from the project
# - ☑️ upgrade a package in the project to latest of available clone data
# - 🚧 support scripts
# - upgrade all packages in the project to latest of available clone data
# - change project file, update lock file from this project metadata (update?)
# - "apt update" for all packages in the project (no changes?)
# - is the update + upgrade split necessary? Maybe we just need to have an --offline option?

use overlays.nu
use paths.nu
use package.nu
use project.nu
use repo.nu
use versions.nu

export def activate [] {
    # todo needs to clone repo and create worktree if not already
    # todo should not be able to add sub-module of a package if it exists
    project read | overlays set-active
}

# Add the package to the current project.
# A package can be a fully-defined id, or a short code for a package that has already
# been added to a project on the system where the full id can be tab-completed.
export def add-package [
    package: string    # The package reference URL, which could be local or remote
    --type: string = "module" # The type of the package, currently only module is supported todo
    --category: string = "runtime" # The category of dependency, either runtime or development
    --version: string  # The version of the package to add, or latest if not specified
] {

    let pkg = $package | package from id
    let project = project read
    let existing = $project | project find dependency $pkg
    if $existing != null {
        error make { msg: $"Package already exists in project: ($package)" }
    }

    $project | upsert-package $package $pkg $category --version $version

    # todo if project activated, print message that shell needs to be-reactivated

    ignore
}

export def remove-package [ package: string ] {
    let pkg = $package | package from id

    let project = project read
    if not ($project | project has dependency $pkg) {
        error make { msg: $"Package doesn't exist in project: ($package)" }
    }

    $project
        | project remove dependency $pkg
        | project write

    ignore
}

# Update packages in the project to the latest available.
export def update-packages [] {
    mut project = project read
    let dependencies = $project | project dependencies
    for package in $dependencies {
        let pkg = $package.id | package from id
        # todo move the project write to calling function so we only need to do once
        # todo  that will also avoid any partial updates
        $project = $project | upsert-package $package.id $pkg $package.category
    }
}

# Update package information being currently tracked.
# todo Option to update package(s) from the local clone, not the remote source?
export def update-package [
    package: string # The package reference
    --version: string  # The version of the package to add, or latest if not specified
    --offline        #
] {
    let pkg = $package | package from id
    let project = project read
    let existing = $project | project find dependency $pkg
    if $existing == null {
        error make { msg: $"Package doesn't exist in project: ($package)" }
    }
    $project | upsert-package $package $pkg $existing.category --version $version
}

def upsert-package [
    id: string
    pkg: record<host: string, path: string, fragment: string>
    category: string
    --version: string
]: record -> record {

    let project = $in

    let clone_dir = $pkg | paths clone-dir
    $clone_dir | repo clone $id
    # todo we don't need to update if we just cloned fresh
    $clone_dir | repo update

    let versions = $clone_dir
        | repo tags
        | select tag revision
        | versions resolved
    print $versions

    let tag = if $version == null {
        $versions | versions latest
    } else {
        $versions | versions locate $version
    }

    let pkg = $pkg
        | insert ref $tag.tag
        | insert version $tag.version
        | insert revision $tag.revision
    print $pkg

    let worktree = $pkg
        | paths revision-dir
        | repo work upsert $clone_dir $pkg.revision
    #print $worktree

    $project
        | project upsert dependency $category $pkg
        | project write

    # todo if project activated, print message that shell needs to be-reactivated
}


# todo list versions in a table, which is reverse semver sorted
