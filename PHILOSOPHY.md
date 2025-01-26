# The Philosophy of Nut

This pages lays out the Nutopean Philosophy driving this project. Or, in less whimsical terms, the background thinking for what a modern package manager should be.

This is not to say that a Nutty approach will solve all mentioned problems, only that they are acknowledged and considered as part of the design. To mitigate what we can as functionality is delivered. Basic functionality first. A bad Nut is one that nobody wants to crack open.

Much of this document is based on modern packaging and security good practice. Where a section strays into the realm of the opinionated, it is noted as such.


## Package Security

Registries and open source projects are being bombarded by various forms of attacks in recent years, including:

- **Typosquatting**: Packages named similarly to popular ones, perhaps with common mispellings or typos.
- **Dependency confusion/substitution/upgrade attacks**: Uploading names of internal packages to public registries where misconfigured tools and registries offer up high-version numbered malicious packages rather than the organisation ones.
- **Package name squatting**: Registering common names of packages or organisations to lock out legitimate use, simply because they got there first.
- **Package name squatting**:
- **Metadata tampering/spoofing**: Posing as a legitimate package by crafting metadata that makes it appear legitimate.
- **Dependency chain attacks**: Rather than attempting to attack a mature package with a strong open source community around it, it is often far easier to attack one of its less well maintained dependencies.
- **Package hijacking**: Compromising developer accounts and uploading malicious versions of their packages.
- **Weakness injection attacks**: Posing as a legitimate open source contributor and intentionally injecting vulnerabilities into a package in the guise of useful new functionality.
- **Package Manager Attacks**: Functionality that allows arbitrary code to run as part of dependency resolution and build opens an unnecessary attack vector that would run prior to any code-based security scanning.

The presence of a package index doesn't solve any of these issues and in fact often creates the problem. Worse, with the advent of Gen AI and being able to create sophisticated attacks at scale, the problem is only going to get worse.


## Trust

So, would you trust a package simply because it's on pypi or npm? Of course not. Anyone can publish to a central package registry. Some registries provide author signing and validation, but with a mix of verified and non-verified packages, it's difficult for a consumer to validate, particularly at scale and long chains of transitive dependencies.

What about if you could:

- Securely validate the author or organisation and the packages they create?
- Assess reputation in the niche where the author/organisation operates?
- Access the status of any particular dependency you are using, directly or indirectly? It might have been popular one, but is it still maintained?

The key would be to adopt modern practices that provide authentictity and make the various factors that would affect trust visible. In concrete terms, this would mean integrating technologies and specifications like:

- Authenticity: Sigstore's [Cosign](https://github.com/sigstore/cosign)
- Project Health: [OpenSSF Scorecard](https://openssf.org/projects/scorecard)
- SPDX License Checks: [SPDX](https://spdx.dev)
- Security Specification: [Supply Chain Levels for Software Artifacts (SLSA)](https://slsa.dev)

Let's just Nut the obvious and say that none of this requires a package registry.

What is clear is that it needs to be trivial to perform by a package author and somewhat conflictingly with stated goals, protect personal information.


## Distributed Model

A central package registry provides a single point of failure for the entire ecosystem. If the registry is compromised, all packages are compromised. If the registry goes down, all packages are unavailable. If the registry is slow, all packages are slow.

Reasonably concerns and in most cases unlikely enough not to be major concerns. However, if the registry is unnecessary, why have it at all?


## Multiple Points of Failure

Adding a distributed model for package management and having an outage of one package source remove the ability to use the intended project is a valid concern. It would be quite easy to make availability worse.

However, leveraging tools such as Git, which is already distributed, and the ability to mirror repositories as a part of normal operation, can mitigate this risk. For the enterprise, some of the enterprise caching proxy managers available today also support Git repositories in the same way as they do for other package types.

It doesn't make the problem go away, and ill-fitting choices for binary hosting by package authors create problems for corporate IT, but a Nut-flavoured pressure to make it easy to do the right thing and hard to do the wrong thing may be helpful in making Nushell easy for enterprise-level adoption.


## Discovery

This is what a package index is uniquely suited to solve and at scale. It's also not a problem that needs to be solved until scale demands it, or by the package manager itself.


## Scale

While Nushell is popular, there is unlikely the dedicated resourcing required to vet new packages and/or remove malicious ones with a reliable community-provided SLA. Operating a package index is likely to be an interesting challenge, but a lot of the time it doesn't sound fun. Instead, the focus should be on using technology to reduce the need for an index, and to put the visibility and power in the hands of the package consumer. 
