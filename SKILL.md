---
name: commit-msg-generator
description: Analyzes staged git changes and produces conventional commit messages with auto-detected type and scope.
version: 0.1.0
license: Apache-2.0
---

# Commit Message Generator

## Purpose

Automatically generate conventional commit messages by analyzing your staged git changes. The tool detects the commit type (feat, fix, refactor, docs, chore, test, style) and scope from the diff, producing messages that follow the Conventional Commits specification.

## See It in Action

Start with [examples/basic-example.md](examples/basic-example.md) to see the simplest usage.

## Examples Index

- **[basic-example.md](examples/basic-example.md)** — Stage changes, run the script, get a commit message
- **[common-patterns.md](examples/common-patterns.md)** — Multi-file commits, scope detection, type inference
- **[advanced-usage.md](examples/advanced-usage.md)** — Override type/scope, verbose mode, piping to git commit

## Reference

### Options

| Flag        | Description                              |
|-------------|------------------------------------------|
| `--type`    | Force commit type (feat, fix, etc.)      |
| `--scope`   | Force scope (overrides auto-detection)   |
| `--verbose` | Show reasoning for type/scope decisions  |
| `--quiet`   | Output only the message (for piping)     |
| `--help`    | Show usage information                   |

### Commit Types Detected

- `feat` — new files, new functions, "add" keywords
- `fix` — "fix", "correct", "patch", "resolve" keywords
- `refactor` — renames, restructuring, no behavior change signals
- `docs` — markdown/doc-only changes
- `chore` — config files, dependency updates, CI changes
- `test` — test file changes only
- `style` — whitespace, formatting, semicolons

## Installation

No dependencies beyond `bash` and `git`. Copy `scripts/run.sh` to your project or run directly.
