# Package Id

In a distributed package system, a reference to a package needs to be globally unique. The disadvantage of a distributed approach being that the package name will necessarily be longer.


# Unique Identifier

The package `name` is the same as many package management tools would represent the `name` of the package. In a distributed system, this `name` would need to be a globally-unique reference. Since the package is sourced from this identifier, there is no ambiguity between this and other packages, and only the owner of this repository would be able to publish packages.

With a unique identifier, typo-squatting attacks become more obvious. For example, a package being installed from `nushell/nupm` rather than `attacker/nupm`. Contrast this with `npm install bable` or `pip install reqests` where the typos in both places are easy to miss.

Given this kind of package id is longer than a package name in a system that has a registry, that at least has the benefit as it's less likely to be typed wrongly and more likely copy/pasted. There is also the issue with a typo in the provider `github.com/microsoft/azure-cli` versus `github.com/microsft/azure-cli` but at the same time, such blatant organisation name squatting on providers like GitHub seems less likely than for any particular package.

If a repository is renamed or moved withing a Git hosting provider, an HTTP redirect is usually performed. This means that the `id` can be considered stable even if the repository is moved. However, we should emit a warning for usages to update.

It isn't ideal to have a package id that is a direct location of a package, but the simplicity benefits outweigh the downsides, and Nut is far from the only package manager to take this approach.


## Required Information

For our purposes, we would want to encode the following information:
- The name of the package to both uniquely identify and locate it.
- The context within the package that should be used.


## URIs

Nut could have used a URI to classify packages as it's a convenient and standard unique identifier for the package. However, it's longer than really necessary and it begs the question of what would be the scheme.

Exploring that, tye disadvantages to using a URI are:
- Using `nut://` on every package is redundant.
- Adding something for our different types of packages would be useful, but that would suggest something like `git://` but this might imply Nut uses Git's unsecured protocol, so it's best to avoid the confusion.
- Users may assume the URIs we specify are also URLs, which is not necessarily the case. The mechanism to retrieve the package may depend on the type of module for example.


## Id

Nut uses `https://<domain>/<path>` as it's short enough and used by other package managers like Go and Docker so it would likely be more familiar.

A package manager should not allow the ability to specify user information or port as part of our URI as they are no part of the unique name and a security risk. These should be configured elsewhere.


## Resource Types

A package manager for Nushell should support scripts, modules and plugins. While scripts and modules can be stored in a Git repository, plugins are compiled binaries and should be stored in a binary repository. In each case, we should support industry standards.

It seems better these are specified separately from the name, though we'll need to think about whether it is valid to have two packages with the same name but different types. This is likely to be a rare and for now we'll assume it's not allowed.


### Local "Remotes"

Contrary to Git remotes above, an `id` for a package could also be a local path. It's unlikely a project will be published in this format it's likely convenient. While a mirroring mechanism is needed elsewhere that also could be used for this, we should support local paths for a package for convenience.

This can simply be indicated a non-domain format of the name, indicating it's a local package. For example:

```
file:///home/user/path/to/package
```

We need to pay attention on how to support both absolute and relative paths, as well it as it being able to work on both Unixy-style and Windows filesystems.

### Monorepos

In addition, we should support the ability to specify a sub-path within the repository. This is useful for monorepos, where a single repository contains multiple packages. Given a Nushell repository is often likely to be a collection of small modules, a package manager requires first-class support for this kind of project organisation.

```
github.com/org/project#some/module
```

This leverages the "fragment" part of the URI spec to reference a `semver` module within the `nut` repository. This makes it clear to the package manager that it should clone the Git repository and then look for the `semver` module within it.

This also allows a single id field to reference both a repository-level module in the same way as a submodule several levels deep.

Additionally, single files can be referenced as modules in the same way:

```
github.com/org/project#some/path/module.nu
```


### OCI Registry

The OCI Registry will be used for plugins. While OCI registries are commonly used for container images, they fully support other artifacts, such as Helm charts. Additionally, if a project located on GitHub, it is relatively easy to publish an OCI bundle into GitHub's OCI-supporting Container Registry, `ghcr.io`.

This scheme is yet to be defined. However, it is likely the best strategic choice for storing compiled binaries, should a package require them, or depend on a package that requires them. 


## Versioning

The package reference uniquely identifies the location of the package. It does not imply what version to use.

Referencing a specific package version is a separate concern as we would commonly want to be able to specify version bounds, for example depend on `1.0.*`, which would suggest I am happy to update to the latest patch version, but not automatically to `1.1.0`
