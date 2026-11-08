---
name: man
description: Explain a tool
---

The user want to ad-hoc generate a manual for a given tool.

## Which Tool

The user should name the tool as an argument. If not you may infer from context if it is obvious, but ask if there are ambiguities. 

Pick an appropriate tool from the argument.

* First, if the argument matches a skill or built-in agentic functionality.
* Second, check if there is a matching cli command.
* Third, check in the local repo or the overall context for the task if there is a tool that matches 

## The Manual

The ad-hoc manual is lightweight and should fit within a half or at-least a full page.
The manual does not need to be complete, the user will ask follow up questions if needed.

* Summary - explain in up to three sentences what the tool does
* Examples - provide up to four examples of how to invoke the tools with different args and what that does
* Key aspects - provide up to five bullet points of key considerations when using the tool, which might not be obvious