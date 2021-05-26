# Naming things

One of the hard problems, but surprisingly few resources on how the solve this problem.

# Principles

1. Maximize meaning and intention
2. Minimize length of name
3. Consistency across codebase and organization
4. Avoid confusion with other concepts

The principle #1 and #2 form a tradeoff, a cost-benefit for adding stuff to the name. In some instances #3 and #4 also form a tradeoff, where you need to decide when your concept becomes different.

This is also always context dependent. A variable can be named `x` in a lambda expression but not in a database. If the name is within a context

## Avoid useless words

Principles #1 and #2 gives us that words do not carry meaning should be dropped. Don't use generic names like `Data`, `Info` or `Manager`.

Prefer domain concepts to implementation and tech concepts.

# Finding good names

## Namestorming

Write down as many names as you can think of, and then pick the best. If you have multiple people doing this you can also cross pollinate between names.

## Write a sentence

Write a full english sentence describing the name, and then shorten it down to a name.