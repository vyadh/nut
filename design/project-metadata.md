# Project Metadata

## Example `nut.nuon` Project File

```nushell
{
  id: "github.com/vyadh/nut"
  type: module
  description: "A dependency management Nutopia"
  license: "MIT"
}
```

With Nut, this file is not required to define a package. It is enough for a Git repository to exist with some Nushell code in it.

However, if this package file does exist, these items should be defined and a warning be emitted for nut operations when they are missing, except `id`, which is for informational purposes.

### Id

The `id` is how many package management tools would represent as a `name` of the package. In a distributed system, the `id` needs to be a globally-unique reference. Since the package is sourced from this identifier, there is no ambiguity between this and other packages, and only the owner of this repository would be able to publish packages.

For more on package id URIs and what they mean, see the [Package Id](package-id.md) documentation.

The interesting property of `id` is that it no longer needs to be defined at all in the package manifest other than documentation. This is because the `id` is a property of the location of the repository, not the code itself. This would be similar to container images, which are identified by their registry and name, not by the contents.


### Git Tags

The version of the package is dictated by the tags at that revision. Initially, the package will not be available for publishing without a tag. Or put another way, publishing a package is simply the act of defining a tag.

For development purposes, it might be convenient to "publish" against a stable a branch name but where the commits float. In this case, the `ref` can be used. See the dependencies section for more details.


## Dependencies

The `nut.nuon` file can define dependencies that would be made available to the project. Those dependencies can have their own dependencies.

```nushell
{
  # ...
  
  dependencies: {
    "runtime": {
      "github.com/vyadh/chestnuts": { version: "v2.1.0" }
      "github.com/nushell/nu_scripts/modules/docker": { version: "v0.5.0" }
    }
    "development": {
      "github.com/vyadh/nutest": { version: "v1.0.0" }
    }
  }
}
```

Versioning for sub-modules within a monorepo would follow the same pattern. Where a Git tag may exist for the main repository as `v1.2.3`, a submodule tag could independently exist as `semver/v1.2.3` or inherit the global one.


## Types

We should distinguish what is needed by the package to function at runtime versus what is needed for development to avoid inflicting package choices on consumers unnecessarily.

Some package managers define `optional` rather than `development`, but the concept isn't quite the same in the sense that it may be features that are not necessarily used. For Nushell, the parsing would fail if all packages are not available, so a more concrete type of `development` seems more appropriate.

## References

The use of a `docker` module from `nu_scripts` provides an example of the mono-repo case. This would allow cloning of the repository once, but allow multiple usages of the modules within it across all projects the user has installed.

This also highlights another reason for a lock file based on commit ids. It would be surprising for one project that points at the `HEAD` of some branch to suddenly be using different code because an unrelated project did an update.

According to the [Nupm design document for virtual environments](https://github.com/nushell/nupm/blob/main/docs/design/README.md#separate-virtual-environments-toc), it may be possible to use multiple versions of a module within the same project. This seems like an extremely convenient design feature. However, it seems more like something you'd want to opt-in to rather than as a default. If semantic versioning and bounds of compatibility are being used, it seems optimal to reduce the number of versions of a module in use at any one time. This does assume a sufficiently good resolution algorithm. In either case, this seems like a problem that a nuun implementation would provide, we just need a design to support that usage.
