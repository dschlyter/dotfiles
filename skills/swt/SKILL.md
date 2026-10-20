---
name: swt
description: Switch to and from a (sparse) worktree, thin wrapper around `git swt`
---

Run `git swt` (see `git swt --help`). The last line of output is the target dir.

When creating, decide if the session's work should move into the worktree. User hints (e.g. "new worktree", a branch name, "done" for `-d`) override this.

- Session did work in the repo: commit only the session's changes, on a new branch if on master (`git switch -c <name>`), then `git swt`
- Otherwise the branch and changes are not ours, leave them alone and create a new worktree: `git swt -c [name]`

Then:

- Created a worktree: `EnterWorktree` with that path
- Removed a worktree: `ExitWorktree` with `action: "keep"`, then `cd` to that path
- Failed on uncommitted changes: tell the user, they are not ours to touch
