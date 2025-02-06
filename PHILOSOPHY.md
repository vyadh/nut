# The Philosophy of Nut

This pages lays out the Nutopean Philosophy driving this project. Or, in less whimsical terms, the background thinking for what a modern package manager should be.

This is not to say that a Nutty approach will solve all mentioned problems, only that they are acknowledged and considered as part of the design. To mitigate what we can as functionality is delivered. Basic and stable functionality first. A bad Nut is one that nobody wants to crack open.

Much of this document is based on modern packaging and security good practice. Where a section strays into the realm of the opinionated, it is noted as such.


## Package Security

Supply chain security is a major concern in the software industry. While there may be a number of features that should be added over time to support this, many of the pitfalls can be avoided by the benefit of starting fresh with a design that reduces the impact.

See [Package Security](design/package-security.md) for more details.


## Industry Standards

Where possible we should lean to or encourage proven practices and standards, including:

- [Conventional Commits](https://www.conventionalcommits.org)
- [Semantic Versioning](https://semver.org)


## Supporting Documentation

- [Our Software Dependency Problem](https://research.swtch.com/deps)


## Distributed Model

A central package registry provides a single point of failure for the entire ecosystem. If the registry is compromised, all packages are compromised. If the registry goes down, all packages are unavailable. If the registry is slow, all packages are slow.

Reasonable concerns but in most cases unlikely enough not to be a major issue outside of enterprise settings where the only acceptable dependencies are the ones you have a contract for. However, if the registry is unnecessary, why have it at all?


## Multiple Points of Failure

Naively adding a distributed model for package management and having an outage of one package source remove the ability to use the intended project is a valid concern. It would be quite easy to make availability worse.

However, leveraging tools such as Git, which is already distributed, and the ability to mirror repositories as a part of normal operation, can mitigate this risk. For the enterprise, caching proxy managers available today also support Git repositories in the same way as they do for other package types.

It doesn't make the problem go away, and ill-fitting choices for binary hosting by package authors create problems for corporate IT. A Nut-flavoured pressure to make it easy to do the right thing and hard to do the wrong thing may be helpful in making Nushell easier for enterprise-level adoption.


## Discovery

Discovery is what a package index is uniquely suited to solve, and at scale. It's also not a problem that needs to be solved until scale demands it, or by the package manager itself.


## Scale

While Nushell is popular, there is unlikely the dedicated resourcing required to vet new packages and/or remove malicious ones with a reliable community-provided SLA. Operating a package index is likely to be an interesting challenge, but a lot of the time it's simply a chore. Instead, the focus should be on using technology to reduce the need for an index, and to put the visibility and power in the hands of the package consumer. 


## Minimal Attack Surface

There are largely two different types of dependencies, those that are required or helpful as part of developing the project itself, and those that are required for a downstream project to use it. We should not inflict our development-level choices downstream or imply they should be required at runtime, along with any vulnerabilitiee they may contain..


## Binaries

Providing binaries is clearly not something that can be achieved directly by a Git-based packaged manager. This is particularly important for Nushell plugins that may have been developed in any language. However, there are various mechanisms that could be used to provide such a feature, including:

- GitHub releases
- Links from metadata to a binary repository similar to [Nixpkgs](https://github.com/NixOS/nixpkgs) or [Winget](https://github.com/microsoft/winget-pkgs).
- Non-opinionated standards-based repository managers and formats such as OCI
