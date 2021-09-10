#!/usr/bin/env python3

# TODO describe script

import subprocess


def main():
    sh("ls -la")


def sh(command):
    subprocess.check_call(command, shell=True)


def sh_read(command):
    return subprocess.check_output(command, shell=True).decode('utf-8')


def get(list, i, default=None):
    if i < 0 or i >= len(list):
        return default
    return list[i]


if __name__ == '__main__':
    main()
