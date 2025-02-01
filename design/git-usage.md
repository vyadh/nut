# Git Usage

Clone a Git repo with `--bare` (implies `--no-checkout`) and use work trees to manage the various usages. 

Need to explore what happens when we need to update and what happens to the working folders.

If we use base, do we need to use `git config core.bare false`?

Each work tree maintains its own HEAD and checkout state.

When running git fetch in the bare repo, worktrees won't automatically update their checked-out branches; we'll need to pull or merge manually.
