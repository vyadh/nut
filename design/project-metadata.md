# Project Metadata

## Example `nut.nuon` Project File

```nushell
{
  id: "github.com/vyadh/nut"
  type: module
  description: "A dependency management Nutopia"
}
```

## Id

The `id` is how many package management tools would represent as a `name` of the package. In a distributed system, the `id` needs to be a globally-unique reference. Since the package is sourced from this identifier, there is no ambiguity between this and other packages, and only the owner of this repository would be able to publish packages.

This provides some level of visibility as it's very obvious a package is being installed from `nushell/nufmt` rather than `attacker/nofnt`. Contrast this with `npm install bable` or `pip install reqests` where the typos in both places are not so obvious.

While it's longer than a package name in a system that has a registry, that is also a benefit as it's less likely to be typed wrongly and more likely copy/pasted. Granted, it does not really help with a typo in the provider `github.com/microsoft/azure-cli` versus `github.com/microsft/azure-cli` but at the same time, such blatant organisation name squatting on GitHub seems less likely than a repo name.


### Git Remotes

The actual URL scheme used to access the `id` is something that is determined by the consumer within their dependencies rather than the package author. That includes accessing a repository via HTTP+Git (the default), via SSH+Git, or even perhaps via a caching proxy.

SSH+Git and other schemes can be supported via configuration as necessary on a per-repo basis. The important property is that a change between SSH and HTTP should not require all `id`'s to change. This cannot be defined in the dependencies either, since any project with transitive dependencies should not dictate the mechanism to downstream users.

Unless specified otherwise, a URL for the example `id` would be `https://github.com/vyadh/nut.git`.


### Local Remotes

Contrary to Git Remotes above, an `id` for a "local" remote should specify the scheme or local path. It's unlikely a project will be published in this format, and given the transparency of where the module is coming from as well as preserving backend caches using the core repository, it seems more important to reflect this than a package such as `github.com/vyadh/nutest` invisibly coming from a local path.


### Git Tags

The version of a package is dictated by the tags at that commit id. Initially, the package will not be available without a tag.

Later perhaps this can be relaxed, such as, in order of preference, the version being derived from:

1. Any `v*` semver pattern of tag, including any matching sub-modules (see below)
2. The branch name of at that commit id, in format `0.0.0-ref`
3. The non-tagged commit id in format `0.0.0-commit`


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
