---
name: swt
description: Switch to or from a (sparse) worktree, thin wrapper around `git swt`
---

Run `git swt` (see `git swt --help`). The last line of output is the target dir.

When creating a worktree, decide if the session's work should move into the worktree. User hints (e.g. "new worktree", a branch name, "done" for `-d`) override this. Use the `-l` flag (leave) to leave behind changes unrelated to the current sesion.

- Session did work in the repo: commit only the session's changes, on a new branch if on master (`git switch -c <name>`), then `git swt -l` (any remaining changes are not ours, they stay in the main repo)
- Otherwise the branch and changes are not ours, leave them alone and create a new worktree with a new branch: `git swt -c [name] -l`

When removing a worktree, commit the session's changes first. Never use `-r` or `-m` unless the user asks.

Then:

- Created a worktree: `EnterWorktree` with that path
- Removed a worktree: `ExitWorktree` with `action: "keep"`, then `cd` to that path