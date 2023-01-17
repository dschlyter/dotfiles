15 years later and you are still learning stuff

# General VIM

## Appending

You can append to registers by using the uppercase.

`qQ` - append to macro q, very useful for fixes
`"Ydd` - append the line to paste register, useful to batch up a bunch of lines

## Commands that I still have not learned

qq - create a macro
qQ - append to the macro - !!!

`gn` go to next match and enter visual mode
`cgn` change next match - this can be repeated with `.` !!!

`ge` and `gE` go backwards to end of last word (aka ge is to e what b is to w) - however `be` should be the same almost always
Increment multiple lines by selecting them and doing `g C-a`

`'.` - go back to last edited region
`''` - go back to

`d2)` is a nice way to grab a code block

## Recursive macros

You can trigger a macro from itself.
A macro will also abort when a / find fails, so this could make something that keeps processing until all matches are done.

## Using vim in scripts

Vim is not made for this, but it is kinda cool for quick hacks.

    vim -T dumb -N -u NONE -n -es -c ':3' -c ':norm ccI CAN CHANGE LINE' -c '/find text' -c 'dd' -c 'wq' some_file

Some flags [explained here](https://stackoverflow.com/questions/18860020/executing-vim-commands-in-a-shell-script)

# Plugins in other IDEs

## Idea vim

[Emulates](https://github.com/JetBrains/ideavim/wiki/Emulated-plugins) a bunch of plugins.

Multicursors are awesome!

* `v` to select multiple lines, and then <Alt-n> to fix a cursor per line. Use `_` to align all if you want.
* <Shift-Alt-Click> to add/remove multicursors anywhere
* <Alt-n> to select current word and add a multicursor, or under visual mode select the next match
* <Alt-x> to skip this match
* g<Alt-n> for case insensitive match

* `aa` and `ia` for argument text-objects
* Use `cxia` (twice)

## VS code vim

* <Shift-Alt-Click> to add/remove multicursors anywhere
* `C-d` or `gb` to select current word and add a multicursor
* `v` to select multiple lines, and then `I` to insert at start of line map xe /^[ .,()]*e/e<CR>