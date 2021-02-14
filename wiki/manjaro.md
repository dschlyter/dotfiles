Pamac / Pacman
==============

### Install

    pamac install <package>
    pamac install --no-upgrade <package> # if you get a conflict, or don't want to download the world

### Remove a package

    pamac remove --unneeded --orphans <package>
    pamac remove -uo <package>

(--orphans removes packages not needed, and --unneeded checks that the package removed is not needed)

And you can just clean up stuff with

    pamac remove -uo

### List installed packages

    pamac list -i

### List dependencies

Or reverse dependencies with -r. Limit large output depth with -d.

    pactree python
    pactree -r python
    pactree python -d 2

### When losing track of mirrors (seems to happen often)

    sudo pacman-mirrors --fasttrack

### Nvidia conflicts

Remove cuda and then reinstall cuda.

    pamac remove --unneeded --orphans cuda

### Nvidia conflicts on update

If pamac update fails with this message:

    if possible, remove linux-latest-nvidia-430xx and retry

It seems to be safe just to remove this package and try again. You can check that a newer driver is installed.
