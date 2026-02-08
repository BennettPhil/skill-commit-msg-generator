# Common Patterns

> The most common ways to use `commit-msg-generator` in practice.

## Pattern 1: New Feature Commit

When you add new files or functions:

```bash
git add src/auth/login.js
./scripts/run.sh
```

Output: `feat(auth): add login module`

## Pattern 2: Bug Fix Commit

When a diff contains words like "fix", "correct", "patch", "resolve", or removes broken code:

```bash
git add src/utils/parser.js
./scripts/run.sh
```

Output: `fix(utils): fix parser edge case handling`

## Pattern 3: Refactoring

When files are renamed, functions restructured, or imports reorganized without behavior change:

```bash
git add src/helpers/
./scripts/run.sh
```

Output: `refactor(helpers): reorganize helper modules`

## Pattern 4: Documentation Changes

When only markdown or doc files are changed:

```bash
git add README.md docs/api.md
./scripts/run.sh
```

Output: `docs: update README and API documentation`

## Pattern 5: Multiple File Types

When the commit spans multiple directories:

```bash
git add src/api/routes.js src/api/middleware.js tests/api.test.js
./scripts/run.sh
```

Output: `feat(api): add routes and middleware with tests`
