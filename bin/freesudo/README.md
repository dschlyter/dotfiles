Add commands that can run as root without user entering password.

Ofc these commands should be restricted. Preferably not taking any input.

Installation
------------

    sudo mkdir -p /opt/sudo
    sudo visudo
    # add the line %admin ALL=NOPASSWD:/opt/sudo/*
    sudo cp env/* /opt/sudo
    add_to_path /opt/sudo
