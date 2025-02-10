
# TODO This top-level module is a PoC.
# TODO It is here to explore what is required from the supporting modules.

# Needed operations:
# - ☑️ add a package to the project
# - ☑️ add required overlays
# - ☑️ support sub-modules
# - 🚧 support scripts
#
# - remove a package from the project
# - upgrade a package in the project to latest of available clone data
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
    --type: string = "module" # The type of the package, currently only module is supported
    --category: string = "runtime" # The category of dependency, either runtime or development
    --version: string  # The version of the package to add, or latest if not specified
]: nothing -> nothing {

    let pkg = $package
        | package from id
        | insert type $type
        | insert version $version

    let clone_dir = $pkg | paths clone-dir

    let project = project read
    if ($project | project has dependency $pkg) {
        error make { msg: $"Package already exists in the project: ($package)" }
    }

    $clone_dir | repo clone $package
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
        | reject version # Use normalised semver-compatible version from the tag (todo: or remove adding above?)
        | insert version $tag.version
        | insert revision $tag.revision
    print $pkg

    let worktree = $pkg
        | paths revision-dir
        | repo work upsert $clone_dir $pkg.revision
    #print $worktree

    $project
        | project add dependency $category $pkg
        | project write

    # todo if project activated, print message that shell needs to be-reactivated

    ignore
}

# todo support remove

# Update package information being currently tracked. If no package is specified,
# update information for all packages in the project.
export def update-package [
    package?: string # The package reference
]: nothing -> nothing {
}

# Upgrade a package to the latest version. If no package is specified, upgrade all
# packages.
export def upgrade-package [
    package?: string # The package reference
    --update         # By default work offline, but with this flag the package sources are updated.
]: nothing -> nothing {
}

# todo list versions in a table, which is reverse semver sorted
