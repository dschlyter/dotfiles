#!/usr/bin/env python3

# TODO describe script

import asyncio
import subprocess


async def main():
    x = await asyncio.gather(
        sh_read('ls -la | grep rw'),
        sh_read('ls -l / | grep r')
    )
    print(x[0])
    print("---")
    print(x[1])


def get(list, i, default=None):
    if i < 0 or i >= len(list):
        return default
    return list[i]


async def sh(cmd):
    sout, serr = await async_sh_exec(cmd)
    if sout:
        print(sout)
    if serr:
        print(serr)


async def sh_read(cmd):
    sout, serr = await async_sh_exec(cmd)
    if serr:
        print(serr)
    return sout


async def async_sh_exec(cmd):
    p = await asyncio.create_subprocess_shell(cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
    stdout, stderr = await p.communicate()

    if p.returncode != 0:
        raise subprocess.SubprocessError(f"Command {cmd} returned {p.returncode}")

    return stdout.decode('utf-8').strip(), stderr.decode("utf-8").strip()


if __name__ == '__main__':
    asyncio.run(main())
