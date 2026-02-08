# Advanced Usage

> Power-user features for customizing commit message generation.

## Override the Type

Force a specific commit type:

```bash
./scripts/run.sh --type chore
```

Output: `chore(deps): update dependency versions`

## Override the Scope

Force a specific scope:

```bash
./scripts/run.sh --scope auth
```

Output: `feat(auth): add new login handler`

## Output Just the Message (for Piping)

Use `--quiet` to suppress everything except the commit message itself:

```bash
git commit -m "$(./scripts/run.sh --quiet)"
```

## Show Reasoning

Use `--verbose` to see why the script chose a particular type:

```bash
./scripts/run.sh --verbose
```

Output:

```
Analyzing staged changes...
  Files: src/api/handler.js (modified), src/api/types.ts (added)
  Detected keywords: "add", "new", "handler"
  Inferred type: feat
  Inferred scope: api (common parent directory)

feat(api): add new handler with type definitions
```

## Breaking Changes

If the diff contains "BREAKING" or major API changes are detected:

```bash
./scripts/run.sh
```

Output: `feat(api)!: redesign authentication endpoint`
