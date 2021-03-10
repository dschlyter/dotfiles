#!/usr/bin/env python3

import subprocess
import click


@click.group(help="TODO write help")
@click.pass_context
@click.option('--dry-run', '-d', help='dry run', is_flag=True, default=False)
def main(ctx, dry_run):
    """
    TODO describe script here
    """
    ctx.obj = {"dry_run": dry_run}


@main.command('command', help="TODO write help")
@click.pass_context
@click.argument('file', required=False, default="*")
def command(ctx, file):
    """
    TODO describe command
    """
    if ctx.obj['dry_run']:
        print("dry run")
    else:
        out = sh_read(f"ls -la {file}")
        print(out)


def sh(command):
    subprocess.check_call(command, shell=True)


def sh_read(command):
    return subprocess.check_output(command, shell=True).decode("utf-8")


if __name__ == '__main__':
    main()
