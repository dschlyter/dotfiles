Pamac / Pacman
==============

### Install

    pamac install <package>
    pamac install --no-upgrade <package> # if you get a conflict, or don't want to download the world

### Remove a package

    pamac remove --unneeded --orphans <package>
    pamac remove -uo <package>

(--orphans removes packages not needed, and --unneeded checks that the package removed is not needed)

### List dependencies

Or reverse dependencies with -r. Limit large output depth with -d.

    pactree python
    pactree -r python
    pactree python -d 2

### When losing track of mirrors (seems to happen often)

    sudo pacman-mirrors --fasttrack

### Nvidia conflicts

    Remove cuda and then reinstall cuda.
