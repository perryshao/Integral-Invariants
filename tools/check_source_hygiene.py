#!/usr/bin/env python3
"""Check source text without modifying files or inspecting vendor binaries."""

from pathlib import Path


def main():
    root = Path(__file__).resolve().parents[1]
    suffixes = {".m", ".c", ".cpp", ".h", ".py", ".sh", ".md"}
    configs = {".editorconfig", ".clang-format", ".gitattributes", "miss_hit.cfg"}
    failures = []
    checked = 0
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root)
        if any(part in {".git", "thirdparty", "legacy", "__pycache__", ".venv", "build"} for part in relative.parts):
            continue
        if not path.is_file():
            continue
        if path.suffix not in suffixes and path.name not in configs:
            continue
        checked += 1
        data = path.read_bytes()
        try:
            text = data.decode("utf-8")
        except UnicodeDecodeError:
            failures.append(f"{relative}: not UTF-8")
            continue
        if b"\r" in data:
            failures.append(f"{relative}: CR/CRLF line endings")
        if text and (not text.endswith("\n") or text.endswith("\n\n")):
            failures.append(f"{relative}: expected one final newline")
        for number, line in enumerate(text.splitlines(), 1):
            if line != line.rstrip(" \t"):
                failures.append(f"{relative}:{number}: trailing whitespace")
            indentation = line[:len(line) - len(line.lstrip(" \t"))]
            if "\t" in indentation:
                failures.append(f"{relative}:{number}: tab indentation")
    for failure in failures:
        print(failure)
    print(f"Checked {checked} text files; {len(failures)} issue(s).")
    return bool(failures)


if __name__ == "__main__":
    raise SystemExit(main())
