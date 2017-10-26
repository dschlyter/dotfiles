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

def main():
    args = parse_args()
    print run("ls -la "+args.first)
    print run("sleep 10")

def run(command, shell=False, canFail=False, output=False):
    try:
        if isinstance(command, str):
            if shell:
                command = ["bash", "-c", command]
            else:
                command = command.split(" ")
        stdout = subprocess.check_output(command)
        if output:
            print stdout
        return stdout
    except Exception as e:
        if canFail:
            return None
        else:
            raise

main()
