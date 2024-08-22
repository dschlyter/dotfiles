# How to use comby

## Dir

Specify the dir with `-d` or just `cd` to it.

## First run to see changes

    comby 'if(:[a]) {:[b]}' ':[b]'

## Then execute with -i

    comby 'if(:[a]) {:[b]}' ':[b]' -i

## Annoying whitespace

Comby is somewhat whitespace forgiving, `' '` can match `'  '`, but will not match `''`. So it can struggle to match both `if() {` and `if(){`.

The fast solution is ...

    comby 'if(:[a])...{:[b]}' ':[b]' -i

Or you can use regex to match both space and non space.

    comby 'if(:[a]):[~ *]{:[b]}' ':[b]' -i

## FIX pattern

If your match template matches on too many things, try adding a FIX prefix in your editor to the things to match.

