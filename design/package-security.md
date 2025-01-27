# Package Security

## Attacks

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

- Authenticity: [Sigstore Cosign](https://github.com/sigstore/cosign)
- Project Health: [OpenSSF Scorecard](https://openssf.org/projects/scorecard)
- SPDX License Checks: [SPDX](https://spdx.dev)
- Security Specification: [Supply Chain Levels for Software Artifacts (SLSA)](https://slsa.dev)

Let's just Nut the obvious and say that none of this requires a package registry.

What is clear is that it needs to be trivial to perform by a package author and somewhat conflictingly with stated goals, protect personal information.
