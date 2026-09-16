---
name: wt
description: Switch to and from worktree
---

When this skill is invoked the user wants to switch the current session to a worktree, or switch back from a worktree.

Check the current working dir (without any tool calls), if it contains `.claude/worktrees` then you are in a worktree.

1. If not in a git worktree, then we should switch to one
2. If in a git worktree, then move work back to the primary repo, and delete the worktree

If the user supplied args to the skill, this might be instructions on branch names, etc. If unrelated to branch names or worktrees, then the args are instructions of work to be carried out once the worktree switch is done.

# Creating Worktree

1. Create a branch, unless one has been created in the session already.
  - Branch should have a descriptive name of the work that is being done, it does not need "worktree-" prefix or similar
  - If no work has been done in the session, then the user should at least submit a branch name. Otherwise abort and ask user for the name.
2. Commit changes to the branch
  - Changes that were made in the current session should be committed to the branch
  - Other unfamiliar changes should **NOT** be committed, this is likely unrelated work
  - If no changes have been made, don't commit anything
3. Rebase?
  - If previous branch was not master, then it might make sense to rebase the branch on master, to remove unrelated commits
4. Create worktree with `git sparse-wt [branch-name]`
  - If the current directory is not the repo root, the script automatically creates a sparse checkout
  - The script outputs the target directory path on the last line
  - Use `EnterWorktree` with the output path to enter the worktree
5. Do any work that the user instructed in the skill args

# Leaving Worktree

1. Commit any local changes to the branch, unless they actually should be discarded
2. Run `git sparse-wt` to remove the worktree
  - The script checks for uncommitted changes and errors if any exist
  - If changes should be discarded, use `git sparse-wt --reset`
  - The script outputs the main repo target directory on the last line
3. Use `ExitWorktree` with `action: "keep"` to leave the worktree (since the worktree was probably created manually, not by `EnterWorktree`, `remove` will be rejected)
4. In the main repo, try to check out the branch. If there are conflicts, abort the checkout — the user would need to clean it up.
  - If the worktree was a sparse checkout, return to the same subdir in the repo
5. Do any work that the user instructed in the skill args