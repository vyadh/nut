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

    # todo this also handles fragment but we have that above - we need to decide how we do it
    let pkg = $package | package resolve $type $version
    let repos_dir = paths repos-dir
    let repo_dir = $repos_dir | path join ($pkg | package repo-path)

    $repo_dir | repo clone $package
    # todo we don't need to update if we just cloned fresh
    $repo_dir | repo update

    let versions = $repo_dir
        | repo tags
        | select tag commit
        | versions resolved
    print $versions

    let tag = if $version == null {
        $versions | versions resolved | versions latest
    } else {
        $versions | versions resolved | versions locate $version
    }

    # todo use HEAD if no version found?

    let pkg = $pkg | insert ref $tag.tag | insert commit $tag.commit
    print $pkg
    #let work_dir = paths versions-dir | path join ($pkg | package commit-path)
    #$work_dir | repo work create $repo_dir $"refs/tags/($tag.name)"

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
