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

Troubleshooting
---------------

## Lightdm does not start

Check logs

    cat /var/log/lightdm/lightdm.log
    cat /var/log/Xorg.0.log
    dmesg

Last time this was nvidia driver issue. There seems to be a driver for every kernel and it is not automatically installed?

Don't trust `mhwd`. It installs the wrong drivers. Don't run it and don't let it mess up xorg.conf. Uninstalling and reinstalling mhwd and mhwd-db seems to maybe fix it? But I've uninstalled it totally. Get your drivers manually.

Install a driver matching your kernel

    uname -r
    pamac list -i G nvidia
    pamac install linux510-nvidia

## Random popup asks for root permissions on startup

This seems to be [Dropbox](https://askubuntu.com/questions/1062568/dropbox-asks-authentication-is-needed-to-run-usr-sh-as-the-super-user)

    find Dropbox \! -user david -print
    chown david -r Dropbox

Setting java version
--------------------

Wrong version might cause Idea not to start for example.

    archlinux-java set java-11-openjdk

Networking
----------

Install some general tooling before you get problems

    sudo pacman -Syu bind whois arp-scan net-tools traceroute

General tips

    nmcli device show
    sudo arp-scan --localnet
    traceroute 8.8.8.8
    ip addr
    ping 8.8.8.8
    ping google.se
