#!/usr/bin/env python3

"""
Synchronize marked sections of repository and local settings files.

Sync two files merging their BEGIN_DOTFILES to END_DOTFILES blocks
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import stat
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


MARKER_RE = re.compile(
    r"(?<![A-Za-z0-9_])(?P<kind>BEGIN|END)_DOTFILES"
    r"(?::(?P<name>[A-Za-z0-9_.-]+))?(?![A-Za-z0-9_.:-])"
)
UTF8_BOM = b"\xef\xbb\xbf"


class SyncError(Exception):
    """An expected error that should skip this sync without a traceback."""


@dataclass(frozen=True)
class Block:
    key: str
    name: Optional[str]
    begin: int
    end: int
    begin_marker: str
    end_marker: str
    content: str


@dataclass
class Document:
    path: Path
    lines: List[str]
    blocks: List[Block]
    bom: bool
    newline: str
    mode: int

    @property
    def by_key(self) -> Dict[str, Block]:
        return {block.key: block for block in self.blocks}


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Three-way merge content inside BEGIN_DOTFILES blocks."
    )
    parser.add_argument("repo_file", type=Path)
    parser.add_argument("local_file", type=Path)
    parser.add_argument("--state-dir", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args(argv)

    try:
        base_file, conflicts, changed = sync(args.repo_file, args.local_file, args.state_dir)
    except (SyncError, OSError) as error:
        print(f"❌ partial sync skipped: {error}", file=sys.stderr)
        return 1

    if conflicts:
        print(
            "⚠️  partial sync used repo content for conflicting hunks in: "
            + ", ".join(conflicts),
            file=sys.stderr,
        )
    if changed:
        print(f"✨ partial sync complete: {args.repo_file} ↔ {args.local_file} (base: {base_file})")
    else:
        print(f"✅ partial sync already up to date: {args.repo_file} ↔ {args.local_file}")
    return 0


def sync(
    source: Path,
    target: Path,
    explicit_state_dir: Optional[Path] = None,
) -> Tuple[Path, List[str], bool]:
    source = source.expanduser().absolute()
    target = target.expanduser().absolute()
    if source == target:
        raise SyncError("repo and local paths must be different")

    source_data = read_regular_file(source, "repo file")
    source_document = parse_document(source, source_data, file_mode(source))

    target_exists = target.exists() or target.is_symlink()
    if target_exists:
        target_data = read_regular_file(target, "local file")
        target_document = parse_document(
            target, target_data, file_mode(target), require_blocks=False
        )
    else:
        target_data = source_data
        target_document = parse_document(target, target_data, source_document.mode)

    base_file = state_path(source, target, state_directory(explicit_state_dir))
    base_exists = base_file.exists() or base_file.is_symlink()
    if base_exists:
        base_data = read_regular_file(base_file, "merge base")
    else:
        base_data = source_data
    base_document = parse_document(base_file, base_data, 0o600)

    source_blocks = source_document.by_key
    target_blocks = target_document.by_key
    base_blocks = base_document.by_key

    source_append = [block for block in target_document.blocks if block.key not in source_blocks]
    target_append = [block for block in source_document.blocks if block.key not in target_blocks]
    ordered_keys = [block.key for block in source_document.blocks]
    ordered_keys.extend(block.key for block in source_append)

    merged: Dict[str, str] = {}
    conflicts: List[str] = []
    for key in ordered_keys:
        source_block = source_blocks.get(key) or target_blocks[key]
        target_block = target_blocks.get(key) or source_blocks[key]
        base_block = base_blocks.get(key)
        base_content = base_block.content if base_block is not None else source_block.content
        label = source_block.name or f"unnamed block {key.split(':', 1)[1]}"
        merged[key], conflicted = merge_content(
            source_block.content, base_content, target_block.content, label
        )
        if conflicted:
            conflicts.append(label)

    new_source = render_document(source_document, merged, source_append)
    new_target = render_document(target_document, merged, target_append)
    changes = []
    if new_source != source_data:
        changes.append((source, new_source, source_document.mode))
    if not target_exists or new_target != target_data:
        changes.append((target, new_target, target_document.mode))
    if not base_exists or new_source != base_data:
        changes.append((base_file, new_source, 0o600))
    write_all(changes)
    return base_file, conflicts, bool(changes)


def marker_on_line(line: str) -> Optional[Tuple[str, Optional[str]]]:
    matches = list(MARKER_RE.finditer(line))
    if not matches:
        return None
    if len(matches) != 1:
        raise SyncError("a marker line must contain exactly one dotfiles marker")
    match = matches[0]
    return match.group("kind"), match.group("name")


def parse_document(
    path: Path,
    data: bytes,
    mode: int = 0o644,
    require_blocks: bool = True,
) -> Document:
    bom = data.startswith(UTF8_BOM)
    payload = data[len(UTF8_BOM):] if bom else data
    try:
        text = payload.decode("utf-8")
    except UnicodeDecodeError as error:
        raise SyncError(f"{path}: only UTF-8 text files are supported ({error})") from error

    lines = text.splitlines(keepends=True)
    blocks: List[Block] = []
    names = set()
    unnamed_index = 0
    active: Optional[Tuple[int, Optional[str], str]] = None

    for index, line in enumerate(lines):
        try:
            marker = marker_on_line(line)
        except SyncError as error:
            raise SyncError(f"{path}:{index + 1}: {error}") from error
        if marker is None:
            continue
        kind, name = marker
        if kind == "BEGIN":
            if active is not None:
                raise SyncError(f"{path}:{index + 1}: nested dotfiles blocks are not allowed")
            if name is not None and name in names:
                raise SyncError(f"{path}:{index + 1}: duplicate block name {name!r}")
            active = (index, name, line)
            continue

        if active is None:
            raise SyncError(f"{path}:{index + 1}: END_DOTFILES has no matching begin marker")
        begin, begin_name, begin_marker = active
        if name != begin_name:
            raise SyncError(
                f"{path}:{index + 1}: block ends as {name!r}, but began as {begin_name!r}"
            )
        if begin_name is None:
            key = f"unnamed:{unnamed_index}"
            unnamed_index += 1
        else:
            key = f"named:{begin_name}"
            names.add(begin_name)
        blocks.append(
            Block(
                key=key,
                name=begin_name,
                begin=begin,
                end=index,
                begin_marker=without_line_ending(begin_marker),
                end_marker=without_line_ending(line),
                content="".join(lines[begin + 1:index]),
            )
        )
        active = None

    if active is not None:
        begin, _, _ = active
        raise SyncError(f"{path}:{begin + 1}: BEGIN_DOTFILES has no matching end marker")
    if require_blocks and not blocks:
        raise SyncError(f"{path}: no dotfiles blocks found")

    return Document(
        path=path,
        lines=lines,
        blocks=blocks,
        bom=bom,
        newline=detect_newline(text),
        mode=mode,
    )


def without_line_ending(line: str) -> str:
    return line.rstrip("\r\n")


def detect_newline(text: str) -> str:
    crlf = text.count("\r\n")
    lf = text.count("\n") - crlf
    cr = text.count("\r") - crlf
    if crlf >= lf and crlf >= cr and crlf:
        return "\r\n"
    if cr > lf and cr:
        return "\r"
    return "\n"


def normalized(content: str) -> str:
    return content.replace("\r\n", "\n").replace("\r", "\n")


def ensure_content_line(content: str) -> str:
    if content and not content.endswith("\n"):
        return content + "\n"
    return content


def merge_content(current: str, base: str, other: str, label: str) -> Tuple[str, bool]:
    current = ensure_content_line(normalized(current))
    base = ensure_content_line(normalized(base))
    other = ensure_content_line(normalized(other))

    with tempfile.TemporaryDirectory(prefix="dotfiles-sync-merge-") as temp_dir:
        temp = Path(temp_dir)
        paths = [temp / "repo", temp / "base", temp / "local"]
        for path, content in zip(paths, (current, base, other)):
            path.write_text(content, encoding="utf-8", newline="")

        command = [
            "git", "merge-file", "--stdout",
            "-L", f"repo:{label}", "-L", f"base:{label}", "-L", f"local:{label}",
            str(paths[0]), str(paths[1]), str(paths[2]),
        ]
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if result.returncode == 0:
            return decode_git_output(result.stdout, label), False

        ours = subprocess.run(
            command[:2] + ["--ours"] + command[2:],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if ours.returncode != 0:
            raise SyncError(git_error(ours, label))
        return decode_git_output(ours.stdout, label), True


def decode_git_output(output: bytes, label: str) -> str:
    try:
        return output.decode("utf-8")
    except UnicodeDecodeError as error:
        raise SyncError(f"git produced invalid UTF-8 while merging {label}: {error}") from error


def git_error(result: subprocess.CompletedProcess, label: str) -> str:
    detail = result.stderr.decode("utf-8", errors="replace").strip()
    return f"git merge-file failed for {label}" + (f": {detail}" if detail else "")


def render_document(
    document: Document,
    merged: Dict[str, str],
    append: Iterable[Block],
) -> bytes:
    blocks_by_begin = {block.begin: block for block in document.blocks}
    output: List[str] = []
    index = 0
    while index < len(document.lines):
        block = blocks_by_begin.get(index)
        if block is None:
            output.append(document.lines[index])
            index += 1
            continue
        output.append(document.lines[block.begin])
        output.append(ensure_content_line(merged[block.key]).replace("\n", document.newline))
        output.append(document.lines[block.end])
        index = block.end + 1

    for block in append:
        if output and not output[-1].endswith(("\n", "\r")):
            output.append(document.newline)
        output.append(block.begin_marker + document.newline)
        output.append(ensure_content_line(merged[block.key]).replace("\n", document.newline))
        output.append(block.end_marker + document.newline)

    payload = "".join(output).encode("utf-8")
    return (UTF8_BOM if document.bom else b"") + payload


def state_directory(explicit: Optional[Path] = None) -> Path:
    if explicit is not None:
        return explicit.expanduser()
    override = os.environ.get("DOTFILES_SYNC_DIR")
    if override:
        return Path(override).expanduser()
    xdg_state = os.environ.get("XDG_STATE_HOME")
    if xdg_state:
        return Path(xdg_state).expanduser() / "dotfiles-sync"
    return Path.home() / ".local" / "state" / "dotfiles-sync"


def state_path(source: Path, target: Path, directory: Path) -> Path:
    script_root = Path(__file__).resolve().parent
    try:
        source_name = str(source.resolve().relative_to(script_root))
    except ValueError:
        source_name = str(source.resolve())
    identity = f"{source_name}\0{target.resolve(strict=False)}".encode("utf-8")
    digest = hashlib.sha256(identity).hexdigest()[:16]
    safe_name = re.sub(r"[^A-Za-z0-9_.-]", "_", source.name)
    return directory / f"{safe_name}-{digest}.base"


def file_mode(path: Path, default: int = 0o644) -> int:
    try:
        return stat.S_IMODE(path.stat().st_mode)
    except FileNotFoundError:
        return default


def read_regular_file(path: Path, description: str) -> bytes:
    if path.is_symlink():
        raise SyncError(f"{description} is a symlink; replace it with a regular file before partial sync: {path}")
    if not path.is_file():
        raise SyncError(f"{description} is not a regular file: {path}")
    try:
        return path.read_bytes()
    except OSError as error:
        raise SyncError(f"could not read {description} {path}: {error}") from error


def atomic_write(path: Path, data: bytes, mode: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as output:
            output.write(data)
            output.flush()
            os.fsync(output.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        try:
            temporary.unlink()
        except FileNotFoundError:
            pass


def write_all(changes: List[Tuple[Path, bytes, int]]) -> None:
    originals: Dict[Path, Tuple[Optional[bytes], int]] = {}
    written: List[Path] = []
    for path, _, mode in changes:
        if path.exists():
            originals[path] = (path.read_bytes(), file_mode(path))
        else:
            originals[path] = (None, mode)

    try:
        for path, data, mode in changes:
            atomic_write(path, data, mode)
            written.append(path)
    except OSError as error:
        rollback_errors = []
        for path in reversed(written):
            old_data, old_mode = originals[path]
            try:
                if old_data is None:
                    path.unlink(missing_ok=True)
                else:
                    atomic_write(path, old_data, old_mode)
            except OSError as rollback_error:
                rollback_errors.append(f"{path}: {rollback_error}")
        detail = f"; rollback errors: {', '.join(rollback_errors)}" if rollback_errors else ""
        raise SyncError(f"could not commit synchronized files: {error}{detail}") from error


if __name__ == "__main__":
    sys.exit(main())
