# Git Usage

## Retrieval

Clone a Git repo with `--bare` (implies `--no-checkout`) and use work trees to manage the various usages. Each work tree would then maintain its own HEAD and checkout state.

Need to explore what happens when we need to update and what happens to the working folders.

When running git fetch in the bare repo, worktrees won't automatically update their checked-out branches. Need to investigate what to do here or whether it's even relevant.


## Authentication

This should clearly be configured separately from the package id.


## URLs

When we need to clone some code, we usually obtain the URL for the Git remote. For example:

```
https://github.com/vyadh/nut.git
```

Translating that into and back from a name for our purposes, would look like:

```
github.com/vyadh/nut
```

Using this format for packages makes it clear to the package manager the unique reference, which should be the same regardless of whether a user is using HTTP, HTTPS, SSH or accessing via a mirror or proxy.
