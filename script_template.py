#!/usr/bin/python

import argparse
import subprocess
import sys
import re
import json
from pprint import pprint

desciption='TODO describe script'

def parse_args():
    parser = argparse.ArgumentParser(description=desciption)
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
    print run("ls -la '"+args.first+"'")

def run(command, shell=False, canFail=False, output=False):
    try:
        parsed = parse_command(command, shell)
        stdout = subprocess.check_output(parsed)
        if output:
            print stdout
        return stdout.strip()
    except Exception as e:
        if canFail:
            return None
        else:
            raise

def parse_command(command, shell):
    if isinstance(command, str):
        if re.search("['\"|]", command):
            shell = True
        if shell:
            return ["bash", "-c", command]
        return command.split(" ")
    return command

def load_conf(path):
    with open(path, 'r') as data_file:
        return json.load(data_file)

def save_conf(path, data):
    with open(path, 'w') as data_file:
        print json.dumps(data)
        json.dump(data, data_file)

main()
