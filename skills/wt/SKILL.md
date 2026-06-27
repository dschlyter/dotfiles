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
2. Commit changes to the branch
  - Changes that were made in the current session should be commited to the branch
  - Other unfamiliar changes should **NOT** be commited, this is likely unrelated work
3. Rebase?
  - If previous branch was not master, then it might make sense to rebase the branch on master, to remove unrelated commits
4. Create worktree
  - Create a worktree under `<repo>/.claude/worktrees/<branch-name>`
  - Use `EnterWorktree` to enter the worktree
  - Switch original repo back to the previous branch, or to master (because git does not allow the same branch in two checkouts)
  - Check out the branch in the worktree
5. Do any work that the user instructed in the skill args

# Leaving Worktree

1. Commit any local changes to the branch, unless they actually should be discarded
2. Use `ExitWorktree` with `action: "keep"` to leave the worktree (since the worktree was created manually, not by `EnterWorktree`, `remove` will be rejected)
3. Delete the worktree with `git worktree remove`
4. In the main repo, try to check out the branch. If there are conflicts, abort the checkout, the user would need to clean it up.
5. Do any work that the user instructed in the skill args