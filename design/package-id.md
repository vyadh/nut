# Package Id

In a distributed package system, a reference to a package needs to be globally unique. One disadvantage a distributed approach has over a traditional registry approach is that the package name will necessarily be longer.


# Unique Identifier

A package `id` is how many package management tools would represent as a `name` of the package. In a distributed system, the `id` needs to be a globally-unique reference. Since the package is sourced from this identifier, there is no ambiguity between this and other packages, and only the owner of this repository would be able to publish packages.

With a unique identifier, typo-squatting attacks become a bit more obvious. For example, a package being installed from `nushell/nupm` rather than `attacker/nupm`. Contrast this with `npm install bable` or `pip install reqests` where the typos in both places are easy to miss.

Given the id is longer than a package name in a system that has a registry, that is also a benefit as it's less likely to be typed wrongly and more likely copy/pasted. Granted, there is still the issue with a typo in the provider `github.com/microsoft/azure-cli` versus `github.com/microsft/azure-cli` but at the same time, such blatant organisation name squatting on GitHub seems less likely than for any particular package.

If a repository is renamed or moved, at least within the same Git provider, an HTTP redirect is done, at least for GitHub. This means that the `id` can be considered stable even if the repository is moved. However, we should emit a warning for usages to update.


## Required Information

For our purposes, we would want to encode the following information:
- The scheme that should be used to retrieve the package.
- The authority providing the package.
- The path of the package within that authority.
- The sub-path within the package that should be used, such as support for monorepos.


## URIs

In order to provide a uniform way to reference packages, we will use [URIs (Uniform Resource Locator)](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier). This provides a familiar way to reference resources, and it is a standard that is widely used.

The one downside is that users may assume the URIs we specify are also URLs, which is not the case. The mechanism to retrieve the package is specific to the package manager. In order to highlight this, we will use specific schemes that are not used for URLs.

A package manager should not allow the ability to specify user information or port as part of our URI as they are no part of the unique name and a security risk. These should be configured elsewhere.

Although rare, it's not ideal that the authority providing a package could change. This might be more likely to happen within an organisation who change their Git hosting provider or internal DNS records. However, this is less of a concern in a distributed package manager, as like Git, the authority does not need to be available to operate, it's just that newer versions may be available at the new location. What is clear is a mechanism to specify a mirror or redirect is required on a per-authority basis, and a per-package basis if the package is moved.

This seems a small concession to achieve obvious an obvious and universal URI to reference packages.


## Resource Types

A package manager for Nushell should support scripts, modules and plugins. While scripts and modules can be stored in a Git repository, plugins are compiled binaries and should be stored in a binary repository. In each case, we should support industry standards.

That leads us to the following schemes:
- `git`: A Git repository for source code.
- `ocir`: An Open Container Initiative Registry for binaries.

### Git

When we need to clone some code, we usually obtain the URL for the Git remote. For example:

```
https://github.com/vyadh/nut.git
```

Translating that into a URI for our purposes, would look like:

```
git://github.com/vyadh/nut
```

Using this format for packages makes it clear to the package manager the unique reference, which should be the same regardless of whether a user is using HTTP, HTTPS, SSH or accessing via a mirror or proxy.

It does seem clear that this translation requires understanding this mechanism. For this reason, we should allow a user to enter a Git URL to optionally add a package, even if that is not what is added to their dependency file.

### Local "Remotes"

Contrary to Git remotes above, an `id` for a package could also be a local path. It's unlikely a project will be published in this format it's likely convenient. While a mirroring mechanism is needed elsewhere that also could be used for this, we should support local paths for a package for convenience.

This could be indicated by an empty authority, indicating there is no authority as it's a local package. For example:

```
git:///home/user/path/to/package
```

### Monorepos

In addition, we should support the ability to specify a sub-path within the repository. This is useful for monorepos, where a single repository contains multiple packages. Given a Nushell repository is often likely to be a collection of small modules, a package manager requires first-class support for this kind of project organisation.

```
git://github.com/vyadh/nut#semver
```

This leverages the "fragment" part of the URI spec to reference a `semver` module within the `nut` repository. This makes it clear to the package manager that it should clone the Git repository and then look for the `semver` module within it.

This also allows a single id field to reference both a repository-level module in the same way as a sub-module several levels deep.


### OCI Registry

The OCI Registry will be used for plugins. While OCI registries are commonly used for container images, they fully support other artifacts, such as Helm charts. Additionally, if a project located on GitHub, it is relatively easy to publish an OCI bundle into GitHub's OCI-supporting Container Registry, `ghcr.io`.

This scheme is yet to be defined. However, it is likely the best strategic choice for storing compiled binaries, should a package require them, or depend on a package that requires them. 


## Versioning

The package reference uniquely identifies the location of the package. It does not imply what version to use.

Referencing a specific package version is a separate concern as we would commonly want to be able to specify version bounds, for example depend on `1.0.*`, which would suggest I am happy to update to the latest patch version, but not automatically to `1.1.0`
