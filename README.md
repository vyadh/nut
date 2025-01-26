# Nut

A design space for a modern and distributed package manager for Nushell.

> Nupm + Nuun + Git + Dodgy Name - Package Index = Nut

*Growing a package management infrastructure from something small and maintainable all the way to a large scale industrial Nutopia.*


## What is Nut?

A package manager *design* that combines the ideas of Nupm and Nuun, many of the design aspirations of Nupm, using the distributed nature of Git as its foundations, with a mind to Secure Supply Chain Security and avoiding the pitfalls of centralised package ~~indicies~~ ~~indexes~~ registries.

Nut is currently a concept and not a package manager per-se. This statement will be updated when it becomes clearer whether it is:
- A exploratory implementation for Nupm
- A foundational library that Nupm can leverage
- A standalone project
- A design for a set of practices needed for a modern package management system
- A nutty set of ideas that go nowhere (hopefully not, but quite possible)


## Prior Art

- [Nupm](https://github.com/nushell/nupm): Nushell's existing experimental package manager and its forward-thinking [design document](https://github.com/nushell/nupm/blob/main/docs/design/README.md).
- [Nupm Add/Update](https://github.com/nushell/nupm/issues/115): Some preliminary thoughts on how to add and update packages in Nupm.
- [Nuun](https://github.com/kubouch/nuun): Experimental package activation experiment for Nupm.


## Conceptional Summary

- **Functional**: Basics first then grow.
- **Modern**: Designed for modern tooling, workflows and environments.
- **Focused**: Targeted towards Nushell-specific concerns (modules, scripts, plugins).
- **Distributed**: Packages are made available via Git repositories.
- **Trust**: A focus on trust and validation.
- **Scalable**: Low maintenance system with zero to few critical dependencies.
- **Reliable**: Comprehensive testing and relevant documentation.


### Nutopian Philosophy

Some background reading into the philosophy of Nut can be found in [The Philosophy of Nut](PHILOSOPHY.md).
