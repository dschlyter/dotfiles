Dotfiles
========

Various dotfiles that are useful.

Installation
------------

There is an installation script that sets (almost) everything up. It mostly just symlinks these into your home directory, with different files used on different platforms.

    git clone https://github.com/dschlyter/dotfiles
    cd dotfiles
    ./install.sh

You may add some flags to install more stuff, the script will tell you what they are.

OS X
----

Run `./osx_essential.sh` for some sane default configs.

Run `./osx_window_mgr.sh` to set up some nice shortcuts. Read the script before running since some customization is needed.

* To use iterm2-settings, open iterm preferences and select load config from file and select com.googlecode.iterm2.plist in the dotfiles dir.
* To export config, open iterm preferences and press save config to file.

Python scripts
--------------

For development in intellij/pycharm go to Project settings > SDK and add bin/python to the pythonpath.
