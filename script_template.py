#!/usr/bin/env python3

import argparse
import subprocess
import textwrap
import os
import unittest
from typing import List


def main():
    # https://docs.python.org/3/library/argparse.html
    global_parser = argparse.ArgumentParser(description='TODO describe script')

    global_parser.set_defaults(handler=lambda *args, **kwargs: global_parser.print_help())
    global_parser.add_argument('--dry-run', '-d', action='store_true')
    sub_ps = global_parser.add_subparsers()

    sp = sub_ps.add_parser('list', help='list some files',
                           formatter_class=argparse.RawDescriptionHelpFormatter,
                           description=textwrap.dedent("""
                            A more detailed explanation of the list command
                            This command will call ls -la with the files provided as arguments
                            """))
    sp.set_defaults(handler=list_files)
    sp.add_argument('files', nargs='*', help='files to list')

    sp = sub_ps.add_parser('hello', help='say hello')
    sp.set_defaults(handler=hello)
    sp.add_argument('first_name', help='your first name')
    sp.add_argument('last_name', nargs='?', help='your last name (optional)')
    sp.add_argument('--bangs', type=int, default=1, help='number of !', metavar='N')
    sp.add_argument('--title', '-t', help='your title (optional)')

    parsed_args = global_parser.parse_args()
    # Note: All handlers must have **kwargs to handle global args
    parsed_args.handler(**parsed_args.__dict__)


def list_files(files: List[str], **global_args):
    if global_args['dry_run']:
        print("ls -la", files)
    else:
        subprocess.check_call(["ls", "-la"] + files)


def hello(first_name: str, last_name: str, title: str, exclamations: int, **global_args):
    names = filter(lambda a: a is not None, [title, first_name, last_name])
    print("Hello", " ".join(names) + ("!" * exclamations))


def sh(command):
    subprocess.check_call(['/bin/bash', '-o', 'pipefail', '-c', command])


def sh_read(command):
    return subprocess.check_output(['/bin/bash', '-o', 'pipefail', '-c', command]).decode("utf-8").strip()


def get(li, i, default=None):
    if i < 0 or i >= len(li):
        return default
    return li[i]


# Inline tests
# Run by setting UNITTEST=1
class Tests(unittest.TestCase):
    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')


if __name__ == '__main__':
    if os.environ.get("UNITTEST") == "1":
        unittest.main()
    else:
        main()
