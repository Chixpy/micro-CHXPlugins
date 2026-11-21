#!/usr/bin/env python3
"""Remove lines from a file when their text appears in one or more other files.

Usage:
    ./checksym.py symbols.txt '*.md'
    ./checksym.py symbols.txt *.md
    ./checksym.py symbols.txt symbols.md symfont.md
    ./checksym.py symbols.txt '*.md' --dry-run --verbose

Rules:
  * If the backup file does not exist, it is created next to the first file
    (same name with a .bak extension). An existing backup is never touched.
  * Each non-empty line of the first file is searched for, as a literal
    case-sensitive substring, anywhere in the text of the search files. If it
    is found in at least one of them, the line is removed.
  * Blank or whitespace-only lines are always kept.
  * The first file is written once at the end, preserving the order of the
    remaining lines and the original trailing newline.
"""

import argparse
import glob
import os
import stat
import sys


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog="filter_symbols.py",
        description=(
            "Remove lines from the first file when their text appears in any "
            "of the search files or glob patterns."
        ),
        epilog=(
            "Example: ./filter_symbols.py symbols.txt '*.md' --dry-run --verbose"
        ),
    )
    parser.add_argument(
        "first",
        help="file to remove lines from (e.g. symbols.txt)",
    )
    parser.add_argument(
        "search",
        nargs="+",
        metavar="SEARCH",
        help="file(s) or glob pattern(s) to search in (e.g. '*.md')",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="simulate the result without modifying files or creating the backup",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="show the removed lines (or the lines that would be removed)",
    )
    return parser.parse_args(argv)


def fail(message):
    print(f"Error: {message}", file=sys.stderr)
    return 1


def backup_path(path):
    """symbols.txt -> symbols.bak"""
    root, _extension = os.path.splitext(path)
    return root + ".bak"


def split_lines(data):
    """Return [(line_number, content, full_bytes), ...].

    The content excludes the line ending and any trailing \\r. The full bytes
    include them, so the file can be rebuilt exactly as it was.
    """
    segments = data.split(b"\n")
    result = []
    for index, segment in enumerate(segments):
        has_newline = index < len(segments) - 1
        full = segment + (b"\n" if has_newline else b"")
        content = segment[:-1] if segment.endswith(b"\r") else segment
        result.append((index + 1, content, full))
    return result


def write_atomic(path, data):
    """Write the file atomically and preserve its permissions."""
    tmp = path + ".tmp"
    mode = stat.S_IMODE(os.stat(path).st_mode)
    try:
        with open(tmp, "wb") as handle:
            handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(tmp, mode)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            try:
                os.remove(tmp)
            except OSError:
                pass


def expand_search_files(patterns, first):
    """Expand glob patterns into a deduplicated list of regular files.

    Returns the list of files and a flag telling whether the target file was
    found and skipped.
    """
    files = []
    seen = set()
    first_real = os.path.realpath(first)
    skipped_target = False

    for pattern in patterns:
        if glob.has_magic(pattern):
            matches = sorted(glob.glob(pattern, recursive=True))
        else:
            matches = [pattern] if os.path.isfile(pattern) else []
        matches = [match for match in matches if os.path.isfile(match)]

        if not matches:
            raise FileNotFoundError(f"no file matches: {pattern}")

        for match in matches:
            real = os.path.realpath(match)
            if real == first_real:
                skipped_target = True
                continue
            if real in seen:
                continue
            seen.add(real)
            files.append(match)

    return files, skipped_target


def main(argv=None):
    args = parse_args(argv)
    first = args.first

    if not os.path.isfile(first):
        return fail(f"file not found: {first}")

    try:
        search_files, skipped_target = expand_search_files(args.search, first)
    except FileNotFoundError as exc:
        return fail(str(exc))

    if skipped_target:
        print(
            f"Warning: the target file was excluded from the search: {first}",
            file=sys.stderr,
        )
    if not search_files:
        return fail("no search files left after excluding the target file")

    try:
        with open(first, "rb") as handle:
            data = handle.read()
        contents = []
        for path in search_files:
            with open(path, "rb") as handle:
                contents.append(handle.read())
    except OSError as exc:
        return fail(f"could not read a file: {exc}")

    bak = backup_path(first)
    if args.dry_run:
        if args.verbose:
            print(f"[dry-run] Backup not created or modified: {bak}")
    elif os.path.exists(bak):
        if args.verbose:
            print(f"Backup already exists (left unchanged): {bak}")
    else:
        try:
            with open(first, "rb") as source, open(bak, "wb") as destination:
                destination.write(source.read())
        except OSError as exc:
            return fail(f"could not create the backup: {exc}")
        print(f"Backup created: {bak}")

    lines = split_lines(data)
    kept = []
    removed = []
    for number, content, full in lines:
        needle = content.rstrip(b" \t\r")
        if not needle.strip():
            kept.append(full)
            continue
        if any(needle in text for text in contents):
            removed.append((number, content))
        else:
            kept.append(full)

    total = data.count(b"\n") + (0 if not data or data.endswith(b"\n") else 1)
    remaining = total - len(removed)

    if args.verbose:
        print("Search files:")
        for path in search_files:
            print(f"  {path}")
        if removed:
            title = (
                "Lines that would be removed:"
                if args.dry_run
                else "Removed lines:"
            )
            print(title)
            for number, content in removed:
                print(f"  {number}: {content.decode('utf-8', 'replace')}")
        else:
            print("No lines to remove.")

    print()
    print(f"Target file:      {first}")
    print(f"Search files:     {len(search_files)}")
    print(f"Total lines:      {total}")
    print(f"Removed lines:    {len(removed)}")
    print(f"Remaining lines:  {remaining}")

    if args.dry_run:
        print("\n[dry-run] No files were modified.")
        return 0

    if not removed:
        print("\nNo lines to remove; the file was not modified.")
        return 0

    try:
        write_atomic(first, b"".join(kept))
    except OSError as exc:
        return fail(f"could not write {first}: {exc}")

    print(f"\nFile updated: {first}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
