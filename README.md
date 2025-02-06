# Nut

A design space for a modern and distributed package manager for Nushell.

> Nupm + Nuun + Git + Dodgy Name - Package Index = Nut

*Growing package management infrastructure from something small and maintainable all the way to a large scale industrial Nutopia.*


## What is Nut?

Firstly, **Nut does not exist**. However, let's not that awkward fact of the 'now' get in the way of a good tagline.

> *Want to use a script somebody pushed to a code repository and you want to use it from your code reliably? Just add a reference to it.*

That's Nut(s).

> *Want your enterprise to adopt Nushell but needs to proxy and cache access to packages with the ability to understand and control what they are consuming at scale?*

That's Nut(s). Nushell going 1.0 might also help 😉.

Nut is a distributed package management concept that was born out of the observation that:

- A package index is not required. 
- Explicit support for a package manager by the code author is not required.
- Industry standards and available infrastructure already provide everything a package manager needs (Git, and optionally an OCI registry and signing infrastructure).

With design considerations that go much further:
- There is a scale of needs from somebody's coding itch to enterprise supported software. Both are valuable to their respective audience. The key is knowing what you're consuming.
- Trust in your open source supply chain is helped more by visibility, digital signatures and definable standards than it is by a package index.
- Today's popular project is tomorrow's bit rot. Metadata for project health has a time axis.


## So what is Nut really?

A package manager *design* that combines the ideas of Nupm and Nuun, many of the design aspirations of Nupm, using the distributed nature of Git as its foundations, with a mind to Secure Supply Chain Security and avoiding the pitfalls of centralised package ~~indicies~~ ~~indexes~~ registries.

Nut is currently a concept and not a package manager per-se. This statement will be updated when it becomes clearer whether it is:
- An exploratory implementation for Nupm (most likely)
- A design for a set of practices needed for a modern package management system
- A foundational library that Nupm can leverage (but let's not dance with chickens and eggs)
- A standalone project (but nobody asked for a competing and unofficial package manager)
- A nutty set of ideas that go nowhere (hopefully not, but also quite possible)


## Prior Art

- [Nupm](https://github.com/nushell/nupm): Nushell's existing experimental package manager and its forward-thinking [design document](https://github.com/nushell/nupm/blob/main/docs/design/README.md).
- [Nupm Add/Update](https://github.com/nushell/nupm/issues/115): Some preliminary thoughts on how to add and update packages in Nupm.
- [Nuun](https://github.com/kubouch/nuun): Experimental package activation experiment for Nupm.
- [Nimble](https://nim-lang.github.io/nimble) the package manager for the Nim programming language.
- [Go Mod](https://go.dev/ref/mod) the module system for the Go programming language.


## Conceptional Summary

- **Functional**: Basics first then grow.
- **Modern**: Designed for modern tooling, workflows and environments.
- **Focused**: Targeted towards Nushell-specific concerns (modules, scripts, plugins).
- **Distributed**: Packages are made available via Git repositories.
- **Trust**: A focus on trust and validation.
- **Scalable**: Low maintenance system with zero to few critical dependencies.
- **Reliable**: Comprehensive testing and relevant documentation.


## Nutopian Philosophy

Some background reading can be found in [The Philosophy of Nut](PHILOSOPHY.md).


## Design

Documentation for the various aspects of our Nutty universe can be found below.

- [Versionless Packaging](design/versionless-packaging.md)
- [Zero Code](design/zero-code.md)
- [Project Metadata](design/project-metadata.md)
