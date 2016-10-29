Dotfiles
========

Various dotfiles I use.

Installation
------------

There is an installation script that sets (almost) everything up. It mostly just symlinks these into your home directory, with different files used on different platforms.

    git clone https://github.com/dschlyter/dotfiles
    cd dotfiles
    ./install.sh # use flag --vundle to setup vim plugins

OS X
----

Run `./osx.sh` for some sane default configs.

* To use iterm2-settings, open iterm preferences and select load config from file and select com.googlecode.iterm2.plist in the dotfiles dir.
* To export config, open iterm preferences and press save config to file.

* To use intellij keymap run (change depending on your current intellij version)

    ln -s $(pwd)/intellij_mac_keys.xml /Users/$USER/Library/Preferences/IntellijIdea2016.2/keymaps
