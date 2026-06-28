## BLUF

Order of code is important - keep related pieces of code together.

But also practice BLUF - bottom line up first.

This means:

1. "main" or primary method should be the first thing in the file, together with api/usage/help instructions
2. then sub functions that contain business logic
3. finally at the bottom generic utilities

In general functions should call down, a function calling one above itself is an anti pattern.

However keep existing code style, this applies primarily to new greenfield code, and existing code should follow established patterns.

## KISS

kiss = keep it simple stupid

Consider the complexity for any addition to the code, sometimes it is better to do nothing that to add a complicated solution.
Simpler code is often preferable to perfect code that handles every edge case.

Gauge how important complexity minimization is from the users intent.

- "add test" = expresses clear intent, test should be added unless it is surprisingly complicated 
- "add test ?" = expresses doubt, consider cost and benefit tradeoff
- "add test kiss" = explicit intent from user to consider complexity, favor simplicity and question the necessity of the addition

## Use Links

When referencing external entities use as many clickable links whenever possible - makes it easy to follow up for context.

For example:

- links to slack threads
- links to code files on github
- links to pull requests

Repeat links in new messages. Even if the link was posed before the user should not have to scroll up to find them.

## Be Concise

In all matters, be concise and to the point.
