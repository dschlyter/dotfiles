## File search

Search non-test files with filter.

    *.scala,!*Test*

## Tips and Tricks

https://www.youtube.com/watch?v=ktRHoLHqu1I

- Smart completion: cmd-shift-space (press twice for more results)
- Shift-F2 to get to previous error
- Extract variable from a raw "new ArrayList<String>()" to create a var without typing it
    - Option-shift-o alt-f to declare final
- Move statement up/down with cmd-shift-arrow (more around functions, etc)

- "r.r" to autocomplete reader.readLine() (autocomplete multiple at a time)
- There is ML assisted completion (and you can configure it to add an indicator)
- Complete boolean function with "!" to invert it
- Postfix completion .var to create a var, .try to surround with try-catch

- Command-j for live templates
- Command-option-t to surround with template (eg. add if statement)

- "Trace current stream chain" when stopping at a breakpoint in a lambda
- You can drag and drop breakpoints, useful if you have conditions
- Add breakpoint that don't suspend but evaluates and expression
- You can have breakpoints that only enable after another breakpoint is hit

- You can make Idea understand that a string is SQL for syntax and validation of DB schemas (also works for other langs)