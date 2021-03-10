## Idea vim

[Emulates](https://github.com/JetBrains/ideavim/wiki/Emulated-plugins) a bunch of plugins.

Multicursors are awesome!

* <Shift-Alt-Click> to add/remove multicursors anywhere
* <Alt-n> to select current word and add a multicursor, or under visual mode select the next match
* <Alt-x> to skip this match
* g<Alt-n> for case insensitive match
* `v` to select multiple lines, and then <Alt-n> to fix a cursor per line. Use `_` to align all if you want.

* `aa` and `ia` for argument text-objects
* Use `cxia` (twice)

## VS code vim

* <Shift-Alt-Click> to add/remove multicursors anywhere
* `C-d` or `gb` to select current word and add a multicursor
* `v` to select multiple lines, and then `I` to insert at start of line map xe /^[ .,()]*e/e<CR>