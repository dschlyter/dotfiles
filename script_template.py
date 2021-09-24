#!/usr/bin/env python3

# TODO describe script

import subprocess


def main():
    print(sh("ls -la | grep rw"))


def sh(command):
    subprocess.check_call(['/bin/bash', '-o', 'pipefail', '-c', command])


def sh_read(command):
    return subprocess.check_output(['/bin/bash', '-o', 'pipefail', '-c', command]).decode("utf-8").strip()


def get(list, i, default=None):
    if i < 0 or i >= len(list):
        return default
    return list[i]


if __name__ == '__main__':
    main()
