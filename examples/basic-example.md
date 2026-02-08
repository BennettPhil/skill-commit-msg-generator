# Basic Example

> Generate a conventional commit message from staged git changes.

## What You Will Learn

The simplest way to use `commit-msg-generator`: stage some changes, run the script, and get a formatted commit message.

## Prerequisites

- Git repository with staged changes
- `bash`, `git`

## Step 1: Stage Some Changes

```bash
echo "console.log('hello');" >> src/index.js
git add src/index.js
```

## Step 2: Run the Generator

```bash
./scripts/run.sh
```

## Step 3: See the Output

Expected output:

```
feat(src): add console log statement to index.js
```

## Step 3: Try with a Bug Fix

```bash
# Fix a typo in a config file
sed -i 's/ture/true/' config.json
git add config.json
./scripts/run.sh
```

Expected output:

```
fix(config): correct boolean typo in config.json
```

## What Just Happened

The script read `git diff --cached` to see your staged changes, detected which files were modified, inferred the type of change (feat, fix, refactor, etc.) from the diff content, and produced a conventional commit message.

## Next Steps

- See [Common Patterns](./common-patterns.md) for multi-file commits and scope detection
- See [Advanced Usage](./advanced-usage.md) for custom types and scopes
