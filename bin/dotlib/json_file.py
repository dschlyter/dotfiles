#!/usr/bin/env python3
"""
Safe concurrent JSON file operations with file locking.
Supports multiple processes reading/writing simultaneously using advisory locks.
"""

import os
import json
import fcntl
import tempfile
import time
from contextlib import contextmanager


@contextmanager
def file_lock(filepath, timeout=10):
    """
    Context manager for acquiring an exclusive file lock.
    Uses advisory locking via fcntl, which is safe for multiple processes.
    """
    lock_path = f"{filepath}.lock"
    os.makedirs(os.path.dirname(lock_path) if os.path.dirname(lock_path) else ".", exist_ok=True)

    lock_file = open(lock_path, 'w')
    start_time = time.time()

    try:
        while True:
            try:
                fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except IOError:
                if time.time() - start_time > timeout:
                    raise TimeoutError(f"Could not acquire lock on {filepath} within {timeout}s")
                time.sleep(0.01)

        yield lock_file
    finally:
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)
        lock_file.close()


def read_json(filepath, default=None):
    """Read a JSON file under an exclusive lock."""
    if not os.path.exists(filepath):
        return default
    with file_lock(filepath):
        with open(filepath, 'r') as f:
            return json.load(f)


def modify_json(filepath, fn, default=None):
    """Read-modify-write a JSON file under a single lock.

    Calls fn(data) which should mutate or return new data.
    If fn returns a non-None value, that becomes the new file contents.
    Otherwise the (presumably mutated) original data is written back.
    """
    parent_dir = os.path.dirname(filepath)
    if parent_dir:
        os.makedirs(parent_dir, exist_ok=True)

    with file_lock(filepath):
        # read
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                data = json.load(f)
        else:
            data = default

        # modify
        result = fn(data)
        data = result if result is not None else data

        # atomic write
        fd, temp_path = tempfile.mkstemp(
            dir=parent_dir if parent_dir else '.',
            prefix='.tmp_',
            suffix='.json'
        )
        try:
            with os.fdopen(fd, 'w') as f:
                json.dump(data, f, indent=2)
            os.rename(temp_path, filepath)
        except:
            if os.path.exists(temp_path):
                os.unlink(temp_path)
            raise


class JsonDir:
    """Wrapper that binds JSON file operations to a base directory.

    Relative paths are resolved against the base directory.
    The directory is created on demand for write operations.
    """

    def __init__(self, base_dir):
        self.base_dir = base_dir

    def _resolve(self, file):
        if os.path.isabs(file):
            return file
        return os.path.join(self.base_dir, file)

    def read(self, file, default=None):
        return read_json(self._resolve(file), default)

    def modify(self, file, fn, default=None):
        """Read-modify-write under a single lock. See modify_json."""
        modify_json(self._resolve(file), fn, default)
