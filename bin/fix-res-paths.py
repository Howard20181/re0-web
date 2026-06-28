#!/usr/bin/env python3
"""
Normalize local mdBook resource paths in markdown files.

GitBook allowed source links like /res/... and rewrote them during output.
mdBook keeps source paths as-is, so markdown files under mdbook/src need links
relative to their own directory. This script is intentionally idempotent: it
normalizes /res/ and any already-converted ../res/ variant to the one correct
relative prefix for each file.
"""
import os
import re
import sys


LOCAL_RES_PATH = re.compile(r"(?<![A-Za-z0-9:/])(?:[./]+)?res/")


def fix_res_paths(src_dir: str) -> None:
    fixed_count = 0

    for root, dirs, files in os.walk(src_dir):
        dirs[:] = [dirname for dirname in dirs if dirname not in {".git"}]

        for filename in files:
            if not filename.endswith(".md"):
                continue

            filepath = os.path.join(root, filename)
            rel_path = os.path.relpath(filepath, src_dir).replace("\\", "/")

            dir_part = os.path.dirname(rel_path)
            depth = len([part for part in dir_part.split("/") if part]) if dir_part else 0
            replacement = ("../" * depth) + "res/"

            with open(filepath, "r", encoding="utf-8", newline="") as f:
                content = f.read()

            if "res/" not in content:
                continue

            new_content = LOCAL_RES_PATH.sub(replacement, content)

            if new_content != content:
                with open(filepath, "w", encoding="utf-8", newline="\n") as f:
                    f.write(new_content)
                fixed_count += 1

    print(f"[fix-res-paths] Fixed {fixed_count} files in {src_dir}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <src_dir>")
        sys.exit(1)
    fix_res_paths(sys.argv[1])