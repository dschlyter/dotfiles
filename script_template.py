#!/usr/bin/env python3

import argparse
import subprocess


def main():
    # https://docs.python.org/3/library/argparse.html
    parser = argparse.ArgumentParser(description='TODO describe script')
    parser.set_defaults(func=lambda args_without_command: parser.print_usage())
    parser.add_argument('-d', '--dry-run', action='store_true')
    subs = parser.add_subparsers()

    sp = subs.add_parser('list', help='list some files')
    sp.set_defaults(func=list_files)
    sp.add_argument('files', type=str, nargs='*', help='files to list', metavar='N')

    sp = subs.add_parser('hello', help='say hello')
    sp.set_defaults(func=hello)
    sp.add_argument('first_name', type=str, help='your first name')
    sp.add_argument('last_name', type=str, nargs='?', help='your last name (optional)')

    args = parser.parse_args()
    if args.dry_run:
        print("There is no dry run")
        return
    args.func(args)


def list_files(args):
    # note: not space safe
    print(args)
    files = " ".join(args.files)
    print(sh(f"ls -la {files} | grep rw"))


def hello(args):
    print("Hello", args.first_name, args.last_name)


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
