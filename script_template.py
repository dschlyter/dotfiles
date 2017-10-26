#/usr/bin/python

import subprocess
import sys
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description='TODO describe script')
    parser.add_argument('-c', '--counter', dest='counter', default=14, type=int,
            help='a simple counter')
    parser.add_argument('-f', '--flag', dest='flag', action='store_true',
            help='a simple flag')
    parser.add_argument('first',
            help='required first arg')
    parser.add_argument('second', nargs='?', default=42,
            help='optional trailing arg')
    return parser.parse_args()

# helper debugging method
def instrospect(object):
    [method_name for method_name in dir(object)
        if callable(getattr(object, method_name))]

def run(command):
    if isinstance(command, str):
        command = command.split(" ")
    return subprocess.check_output(command)

def main():
    args = parse_args()
    print run("ls -la "+args.first)

main()
