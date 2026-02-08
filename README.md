# commit-msg-generator

Analyzes staged git changes and produces conventional commit messages with auto-detected type and scope.

## Quick Start

```bash
git add src/feature.js
./scripts/run.sh
# Output: feat(src): add feature.js
```

## Features

- Detects commit type: feat, fix, refactor, docs, chore, test, style
- Auto-detects scope from file paths
- Detects breaking changes
- Override type/scope with flags
- Pipe-friendly `--quiet` mode

See [examples/](examples/) for more usage patterns.

## Prerequisites

- `bash`, `git`
