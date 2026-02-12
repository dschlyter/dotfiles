## Commands

Getting started

/init - create CLAUDE.md from your repo
    read it yourself to get a feeling for the repository
/cost
/stats
/context - what is my context
/compact - make context smaller
/clear - the best way for smaller context

ultrathink (without /) - do chain of thought preprocessing (32k tokens instead of default 10k), good for hard problems and deep contexts

shift-tab - create an execution plan

Esc - interrupt to give more context
Esc Esc - go back to previous conversation point
/resume previous session - or `claude -c`

/mcp
/skills
/agents
    subagents specialize in a particular task and have their own context window
    permissions can be set per agent
    claude code automatically delegates to subagents when appropriate
/hooks
    custom hooks before/after commands - block file access, auto format, notify, etc
/plugin - custom slash-commands can be installed from marketplace

## VS code integration

cmd-esc to launch / focus
cmd-opt-k to send context
can ask "what file am I in?"

## Good default permissions

For less nagging:

~/.claude/settings.json

{
  "permissions": {
    "allow": [
      "Read(./**)",
      "Grep",
      "Glob",
      "WebSearch",
      "WebFetch",
      "Bash(git log *)",
      "Bash(git show *)",
      "Bash(git diff *)"
    ]
  }
}

## Alert when input is needed

macos alert when prompt is finished or permissions is needed

      "hooks": {
        "Stop": [
          {
            "hooks": [
              {
                "type": "command",
                "command": "afplay /System/Library/Sounds/Glass.aiff",
                "timeout": 5
              }
            ]
          }
        ],
        "Notification": [
          {
            "matcher": "permission_prompt",
            "hooks": [
              {
                "type": "command",
                "command": "afplay /System/Library/Sounds/Submarine.aiff",
                "timeout": 5
              }
            ]
          }
        ]
      }

## MCP

Default is to install in current dir, use --scope project or --scope user for wider scope.

    claude mcp add --transport http [--scope user] <mcp name> <mcp uri>

The check connections and auth

    /mcp 

## Patterns

Hierarchical CLAUDE.md in your directories.

## Claude Agent SDK

The Agent SDK gives you the same tools, agent loop, and context management that power Claude Code, programmable in Python and TypeScript.

- Pattern: Primary agent that can run multiple sub agents