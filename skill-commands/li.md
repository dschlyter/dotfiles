---
name: li
description: Provide a list of options for how to continue
---

Respond to the user with a numbered list of possible next steps.

List should ideally be just one line per item, but if we have few items (<=5), then some more elaboration could be appropriate.

In any case, keep it brief, the user will ask for elaboration if needed.

Put the recommended option first and mark it with ⭐.

Keep numbering stable across follow-ups - after `e 3` the user should still be able to say `3`.

## Response

* User lists items to execute like `1 2 5`, `1-6 9` or `yes 3 4 5` - then do it
* User asks for more context like `explain 3 5` or `e 6-8` - then elaborate, don't do anything yet