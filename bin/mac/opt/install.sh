#!/bin/bash

sudo mkdir -p /opt/sudo
sudo cp sudo/* /opt/sudo/

echo "Scripts installed!"
echo "---"
echo "To enable, run:"
echo "sudo visudo"
echo "And enter:"
echo "%admin ALL=NOPASSWD:/opt/sudo/*"
