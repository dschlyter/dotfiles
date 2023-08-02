#!/usr/bin/env python3

# TODO describe script

import asyncio
import subprocess
import os
import unittest


async def main():
    x = await gather_with_concurrency(
        2,
        sh_read('ls -la | grep rw'),
        sh_read('ls -l / | grep r'),
        sh_read('ls -l / | grep x'),
    )
    print(x[0])
    print("---")
    print(x[1])
    print("---")
    print(x[2])


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


async def gather_with_concurrency(n, *coroutines):
    semaphore = asyncio.Semaphore(n)

    async def with_semaphore(coroutine):
        async with semaphore:
            return await coroutine
    return await asyncio.gather(*(with_semaphore(c) for c in coroutines))


# Inline tests
# Run by setting UNITTEST=1
class Tests(unittest.TestCase):
    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')


if __name__ == '__main__':
    if os.environ.get("UNITTEST") == "1":
        unittest.main()
    else:
        asyncio.run(main())
