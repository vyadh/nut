
# TODO This top-level module is a PoC.
# TODO It is here to explore what is required from the supporting modules.

use paths.nu
use package.nu
use repo.nu
use versions.nu

# Add the package to the current project.
# A package can be a fully-defined id, or a short code for a package that has already
# been added to a project on the system where the full id can be tab-completed.
export def add-package [
    package: string    # The package reference URL, which could be local or remote
    --type: string = "module" # The type of the package, currently only module is supported
    --version: string  # The version of the package to add, or latest if not specified
]: nothing -> nothing {

    let pkg = $package | package resolve $type $version
    let clone_dir = $pkg | paths clone-dir

    # todo check if the package is already added and abort

    $clone_dir | repo clone $package
    # todo we don't need to update if we just cloned fresh
    $clone_dir | repo update

    let versions = $clone_dir
        | repo tags
        | select tag commit
        | versions resolved
    print $versions

    let tag = if $version == null {
        $versions | versions latest
    } else {
        $versions | versions locate $version
    }

    # TODO standardise on "revision" or "commit"
    let pkg = $pkg | insert ref $tag.tag | insert commit $tag.commit
    print $pkg

    let worktree = $pkg
        | paths revision-dir
        | repo work upsert $clone_dir $pkg.commit
    print $worktree

    # add to project
    # add to lockfile
    # use it
}

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
