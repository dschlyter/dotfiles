---
name: wt
description: Switch to and from worktree
---

When this skill is invoked the user want to switch the current session to a worktree, or switch back from a worktree.

Check the current working dir (without any tool calls), if it contains `.claude/worktrees` then you are in a worktree.

1. If not in a git worktree, then we should switch to one
2. If in a git worktree, then move work back to the primary repo, and delete the worktree

If the user supplied args to the skill, this might be instructions on branch names, etc. If unrelated to branch names or worktrees, then the args are instructions of work to be carried out once the worktree switch is done.

# Creating Worktree

1. Create a branch, unless one has been created in the session already.
  - Branch should have a decriptive name of the work that is being done, is does not need "worktree-" prefix or similar
  - If no work has been done in the session, then use should at least submit a branch name. Otherwise abort and ask user for the name.
2. Commit changes to the branch
  - Changes that were made in the current session should be commited to the branch
  - Other unfamiliar changes should **NOT** be commited, this is likely unrelated work
  - If no changes have been made, don't commit anything
3. Rebase?
  - If previous branch was not master, then it might make sense to rebase the branch on master, to remove unrelated commits
4. Switch to the previous branch, or master branch, in the main repo (because git does not allow the same branch in two checkouts)
5. Create worktree
  - Create a worktree with `git worktree add <repo>/.claude/worktrees/<branch-name> <branch-name>`
  - Use `EnterWorktree` to enter the worktree
  - Check out the branch in the worktree
6. Do any work that the user instructed in the skill args

## Sparse Checkouts

If the current dir is not the root of the repo, then we want a sparse checkout. This avoids copying the entire monorepo into the worktree.

When creating the worktree in step 5, replace the normal flow with:

1. Determine the sparse path: the relative path from the repo root to the current directory (use `git rev-parse --show-toplevel` and compare to `pwd`)
2. Create the worktree without checking out files: `git worktree add --no-checkout <repo>/.claude/worktrees/<branch-name>` (you MUST NOT add the branch as a parameter in the end, as that will cause a checkout)
3. Use `EnterWorktree` (with `path`) to enter the empty worktree
4. Configure sparse checkout and check out the branch:
   ```
   git sparse-checkout set <relative-path-to-subdir>
   git checkout <branch>
   ```
5. cd to the subdir within the worktree `cd <repo>/.claude/worktrees/<branch-name>/<relative-path-to-subdir>`

# Leaving Worktree

1. Commit any local changes to the branch, unless they actually should be discarded
2. Use `ExitWorktree` with `action: "keep"` to leave the worktree (since the worktree was probably created manually, not by `EnterWorktree`, `remove` will be rejected)
3. Delete the worktree with `git worktree remove`
4. In the main repo, try to check out the branch. If there are conflicts, abort the checkout, the user would need to clean it up.
  - If the worktree was a sparse checkout, then return to the same subdir in the repo
5. Do any work that the user instructed in the skill args