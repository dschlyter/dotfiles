## BLUF

Order of code is important - keep related pieces of code together.

But also practice BLUF - bottom line up first.

This means:

1. "main" or primary method should be the first thing in the file, together with api/usage/help instructions
2. then sub functions that contain business logic
3. finally at the bottom generic utilities

In general functions should call down, a function calling one above itself is an anti pattern.

However keep existing code style, this applies primarily to new greenfield code and existing code should follow established patterns.

## Use Links

When referencing external entities use as many clickable links whenever possible.

For example:

- links to slack threads
- links to code files on github
- links to pull requests

Repeat links in new messages. Even if the link was posed before the user should not have to scroll up to find them.

## Be Concise

In all matters, be concise and to the point.
