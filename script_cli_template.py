#!/usr/bin/env python3

import click

from dotfiles import run


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
        out = run(f"ls -la {file}", shell=True)
        print(out)


if __name__ == '__main__':
    main()
