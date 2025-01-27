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

### Id

The `id` is how many package management tools would represent as a `name` of the package. In a distributed system, the `id` needs to be a globally-unique reference. Since the package is sourced from this identifier, there is no ambiguity between this and other packages, and only the owner of this repository would be able to publish packages.

This provides some level of visibility as it's very obvious a package is being installed from `nushell/nufmt` rather than `attacker/nofnt`. Contrast this with `npm install bable` or `pip install reqests` where the typos in both places are not so obvious.

While it's longer than a package name in a system that has a registry, that is also a benefit as it's less likely to be typed wrongly and more likely copy/pasted. Granted, it does not really help with a typo in the provider `github.com/microsoft/azure-cli` versus `github.com/microsft/azure-cli` but at the same time, such blatant organisation name squatting on GitHub seems less likely than a repo name.

If a repository is renamed or moved, at least within the same Git provider, an HTTP redirect is done, at least for GitHub. This means that the `id` can be considered stable even if the repository is moved. However, we should emit a warning for usages to update.

The other interesting property of `id` is that it is optional and perhaps should not be defined at all in the package manifest other than documentation. This is because the `id` is a property of the location of the repository, not the code itself. This would be similar to container images, which are identified by their registry and name, not by the contents.

The module file cannot be completely optional however, as we do need to define the type of the package, unless we can infer it from the contents of the repository.


### Git Remotes

The actual URL scheme used to access the `id` is something that is determined by the consumer within their dependencies rather than the package author. That includes accessing a repository via HTTP+Git (the default), via SSH+Git, or even perhaps via a caching proxy.

SSH+Git and other schemes can be supported via configuration as necessary on a per-repo basis. The important property is that a change between SSH and HTTP should not require all `id`'s to change. This cannot be defined in the dependencies either, since any project with transitive dependencies should not dictate the mechanism to downstream users.

Unless specified otherwise, a URL for the example `id` would be `https://github.com/vyadh/nut.git`.


### Local Remotes

Contrary to Git Remotes above, an `id` for a "local" remote should specify the scheme or local path. It's unlikely a project will be published in this format, and given the transparency of where the module is coming from as well as preserving backend caches using the core repository, it seems more important to reflect this than a package such as `github.com/vyadh/nutest` invisibly coming from a local path.


### Git Tags

The version of the package is dictated by the tags at that commit id. Initially, the package will not be available for publishing without a tag. Or put another way, publishing a package is simply the act of defining a tag.

For development purposes, it might be convenient to "publish" against a stable a branch name but where the commits float. In this case, the `ref` can be used. See the dependencies section for more details.


### Monorepos and Submodule Support

Given a Nushell repository is often likely to be a collection of small modules, first-class support for this kind of project organisation is required.

```nushell
{
  id: "github.com/vyadh/nut.git/semver"
}
```

This describes a `semver` module that is located within a sub-directory of a wider repository This allows a single `id` field to reference both a repository-level module in the same way as a sub-module several levels deep.

A `nut.nuon` is expected to exist at any referenced location.

Versioning for sub-modules would follow the same pattern. Where a Git tag may exist for the main repository as `v1.2.3`, a submodule version would exist as `semver/v1.2.3`.


## Dependencies

The `nut.nuon` file can define dependencies that would be made available to the project. Those dependencies that have their dependencies.

```nushell
{
  # ...
  
  dependencies: {
    "runtime": [
      { id: "github.com/vyadh/chestnuts.git", version: "v2.1.0" }
      { id: "github.com/nushell/nu_scripts.git/modules/docker", version: "v0.5.0" }
    ]
    "development": [
      { id: "github.com/vyadh/nutest.git", version: "v1.0.0" }
    }
  }
}
```

## Types

We should distinguish what is needed by the package to function at runtime versus what is needed for development to avoid inflicting package choices on consumers unnecessarily.

Some package managers define `optional` rather than `development`, but the concept isn't quite the same in the sense that it may be features that are not necessarily used. For Nushell, the parsing would fail if all packages are not available, so a more concrete type of `development` seems more appropriate.

## References

The use of a `docker` module from `nu_scripts` provides an example of the mono-repo case. This would allow cloning of the repository once, but allow multiple usages of the modules within it across all projects the user has installed.

This also highlights another reason for a lock file based on commit ids. It would be surprising for one project that points at the `HEAD` of some branch to suddenly be using different code because an unrelated project did an update.

According to the [Nupm design document for virtual environments](https://github.com/nushell/nupm/blob/main/docs/design/README.md#separate-virtual-environments-toc), it may be possible to use multiple versions of a module within the same project. This seems like an extremely convenient design feature. However, it seems more like something you'd want to opt-in to rather than as a default. If semantic versioning and bounds of compatibility are being used, it seems optimal to reduce the number of versions of a module in use at any one time. This does assume a sufficiently good resolution algorithm. In either case, this seems like a problem that a nuun implementation would provide, we just need a design to support that usage.
