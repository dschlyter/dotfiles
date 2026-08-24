---
name: prm
description: General project management - the process for keeping work across multiple Claude sessions aligned with overall goals
---

This is the general AI-augmented project management system to track the goals and process for my personal work, and to keep everything neat, organized and focused.

The process and documentation stored in this system serves as *the bridge* between a multitude of Claude sessions on my machine (in the weeds implementation and investigation) and external systems that capture requirements and plans (high level goals).

External systems may contain information not relevant to my work, vague information or outdated information - so a purpose of this system is to clarify.

# Commands

The user may invoke the skill with different commands, potentially with additional instructions

- **help** - list available commands
- **init** - create a project file for the current project - start should be a lightweight skeleton
- **create** - create a new task in the existing project
- **update** - when the skill is invoked with this command, update the project task relevant to the current session

# File structure

- The main project directory is in `~/projects`
- Every project has its own directory, with a kebab-case name, e.g. `pipeline-v2-migration`
- Every directory represents a in progress project, others are in subdirs `_backlog`, `_cancelled` and `_done`
- Inside a project is a file `_<project-name>.md` describing the overall state
- Each task inside a project can have a subtask file `<subtask>.md`
- Tasks can also be moved to subdirs if not in progress: `_backlog`, `_cancelled` and `_done`
- The `_reference` directory can contain more files with in depth documentation or results

**Example**

```
~/projects/
  _backlog/
  _done/
  pipeline-v2-migration/
    _backlog/
      decommission-v1.md
    _done/
      audit-v1-pipelines.md
    _pipeline-v2-migration.md
    migrate-core-pipelines.md
    update-consumer-configs.md
```

## Guiding Principles

Primary focus of this project system is:

- **conciseness** - Project files should be easy to read at a glance, and might be read by a human multiple times. Laser focus on the key issues, and leave in depth elaborations for `_reference` files or references to external documents.
- **correctness** - All information should be trustworthy.

In order to ensure correctness, follow this process:

1. Launch subagents to investigate and confirm statements entered into project are correct
2. Confirm with the user if there are uncertainties - but try to avoid bothering the user if possible
3. Reference external documentation, or put information in `_reference` files if not certain.
4. Be explicit about the uncertainty in the project documentation
5. Consider just omitting the information. No information is better than incorrect info.

## File content

Every main project should have this information.

- **Description** - A short description, up to three sentences, of what this is about
- **Impact** - Why are we doing this, what is the success criteria and definition of done. If this is unclear, make the lack of clarity explicit.
- **Tasks** - What needs to be done. List of tasks where every item has 
  1. status in brackets `[Backlog]`, `[In Progress]`, `[Done]`.
  2. kebab-case name of task like `decomission-v1`
  3. one line description of task
- **References** - A list of references to external resources relevant for the project or task. Every reference includes a one line description.
  - Jira tickets
  - Google docs
  - Slack conversations
  - Pull requests
  - Claude sessions (by session id) on this device

Task files also have this context 

## Task Creation

Tasks should only be created if the user explicitly asked for them. The list of tasks does not need to be complete and can be expanded later.

First update the plan to ensure the users intent is captured, handle any suggestsion for more tasks later on.

# Tmux integration

Work on this machine will be carried out in Claude running in tmux

* A tmux session will correspond to the project, and probably have an identical name (with a numbered prefix, e.g. `5-pipeline-v2-migration`)
* The windows of the tmux session will have names that correspond to either:
  - A task (e.g. `decomission-v1`)
  - A aspect of the task (e.g. `decomission-v1-test-run`)
  - A aspect of the project itself, without a task (e.g. `investigation`)

This link between tmux windows and the project should make it possible both to read into the Claude session additional context for the task, as well as updating the project with results from the session.

## Investigating Claude sessions

The `cma` command can find links between Claude sessions and project tasks.

- `tmus ls` lists Tmux sessions and the name (matching the project) of them
- `cma who -v <tmux session id>` or `cma who -vs` (current session) - lists the claude sessions in the tmux session
- `cma show <uuid>` describe the content of the session to understand what it does

# Git backed

The project dir should be backed by git.

Changes should be tracked by git, but all changes must be signed off by the user. Once a change has been done, ask the user if it is good to commit (or they may commit themselves).

If uncommited changes are found, and it is more than 24h old - ask the user on how to handle this. Don't read the files themselves, but list the changed files to the user.