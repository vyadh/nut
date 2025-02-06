# Git Usage

## Retrieval

Clone a Git repo with `--bare` (implies `--no-checkout`) and use work trees to manage the various usages.

Need to explore what happens when we need to update and what happens to the working folders.

When running git fetch in the bare repo, worktrees won't automatically update their checked-out branches. Need to investigate what to do here or whether it's even relevant.


## Authentication

This should clearly be configured separately from the package id.


## URLs

When we need to clone some code, we obtain the URL for the Git remote. For example:

```
https://github.com/vyadh/nut.git
```

The important parts being the host and significant path.

```
github.com/vyadh/nut
```

Using this information for packages makes it clear to the the unique reference ie the same regardless of whether a user is using HTTP, HTTPS, SSH or accessing via a mirror or proxy.
