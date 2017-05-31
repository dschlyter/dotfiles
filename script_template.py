#/usr/bin/python

import subprocess
import sys

def run(command):
    if isinstance(command, str):
        command = command.split(" ")
    return subprocess.check_output(command)

print run("ls -la "+sys.argv[1])
