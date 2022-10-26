# Zsh

Zsh-specific features

## Cool for loops

You can skip the ceremonial do and ; done

    for x in a b c; echo $x

## Shell tricks

### Sum first column

cat file | awk '{print $1}' | paste -sd+ - | bc