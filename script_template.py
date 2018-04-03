#!/usr/bin/env python

import argparse
import subprocess
import sys
import re
import json
from pprint import pprint
from tempfile import TemporaryFile

description='TODO describe script'


def parse_args():
    parser = argparse.ArgumentParser(description=description)
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


# high level fire and forget execution
def run(command, shell=False, can_fail=False, output=False):
    parsed = parse_command(command, shell)
    if not output:
        try:
            return subprocess.check_output(parsed).strip()
        except subprocess.CalledProcessError as e:
            if can_fail:
                return None
            else:
                raise
    else:
        ret_val = subprocess.call(parsed)
        if not can_fail and ret_val != 0:
            raise Exception("command returned "+str(ret_val))
        return ret_val == 0


# more low level interface returning return value, stdout and stderr
# modified from https://stackoverflow.com/questions/30937829
def execute(command, shell=False):
    with TemporaryFile() as t:
        try:
            parsed = parse_command(command, shell)
            out = subprocess.check_output(parsed, stderr=t).strip()
            t.seek(0)
            return {"ret": 0, "stdout": out, "stderr": t.read().strip()}
        except subprocess.CalledProcessError as e:
            t.seek(0)
            return {"ret": e.returncode, "stdout": None, "stderr": t.read().strip()}


def parse_command(command, shell):
    command_list = parse_into_arguments(command, shell)
    return map(lambda arg: arg.encode('ascii', 'replace'), command_list)


def parse_into_arguments(command, shell):
    if isinstance(command, str) or isinstance(command, unicode):
        if re.search("['\"|><]", command):
            shell = True
        if shell:
            return ["bash", "-c", command]
        return command.split(" ")
    elif isinstance(command, list):
        return command
    else:
        raise Exception("Unsupported type issued to command")


def load_conf(path, default_value=None):
    try:
        with open(path, 'r') as data_file:
            return json.load(data_file)
    except:
        return default_value


def save_conf(path, data):
    with open(path, 'w') as data_file:
        json.dump(data, data_file)


if __name__ == '__main__':
    main()
