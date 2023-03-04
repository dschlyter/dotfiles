# CLI

Various CLI tricks

## Generate a range of dates

    for i in $(seq 90); do date -I -d "2020-01-01 +$i days"; done

## Ad hoc python

Python can be more flexible than arcane cli tools for stuff.

E.g. multi-line replace

    cat actions.yaml | grep -E '(^[^ ])|(description)' | python -c 'import sys; print(sys.stdin.read().replace("\n "," "), end="")'

## Nice utils

What do I actually use

* fzf, of course
* fd

Want to try

* [jc](https://kellyjonbrazil.github.io/jc/) seems nice
