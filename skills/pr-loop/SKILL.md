---
name: pr-loop
description: Loop to keep a PR green and mergable
---

# 1. Use existing PR

If the user has supplied a PR, or if a PR was created in the current session, then use that PR for looping over.

# 2. Create PR if missing.

(skip this step if PR already exists)

First of all, ensure code is in a good state.

- compile
- run tests
- format code
- run linters

Check AGENTS.md or CLAUDE.md, and README.md for which tools and checks are applicable.

If these have been run recently in the session, then they can be skipped.

Once code is in a good state, create a branch (if on master), commit and create a PR with a good description.

# 3. Loop to make the PR green

Check the build results for the PR - if they are not green then try to fix it. Run relevant local checks, then push the fix and wait until the next loop to inspect the result.

Start a loop where "recheck PR" is invoked every 5 minutes.

## Graceful backoff

- If loop has detected no changes (commits or comments) for 1 hour, reduce to 15 minute loop
- If loop has detected no changes for 2 hours, reduce to 1 hour loop

# 4. (optional) Notify for review

Once the build is green the PR can be reviewed.

If the user has supplied a slack channel, then post a link to the PR in that channel and ask for a review.

# 5. Check for comments

Keep the loop running. Check for any comments on the PR.

If comments are made on the PR, check if they make sense.

1. If comment makes sense, try to fix it, push a fix and reply to the comment.
2. If comment does not make sense, explain why the fix should not be implemented.
3. If comment is just a question, try to provide relevant context, but be clear what you are not sure about.

Again, run local checks before pushing, and check the build result of any pushes.

# 6. (ONLY if instructed) Merge

If the user has instructed "merge" when invoking the skill, then merge the PR once it is approved and the build has passed.

If no clear merge instruction has been made, then just keep watching the PR.

Avoid merging if major changes have been made due to comments or build issues.

# 7. Exit loop

When PR is merged or closed, terminate the loop