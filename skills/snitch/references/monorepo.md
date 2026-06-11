# Monorepo Scanning

Detect and handle monorepo structures for targeted scanning.

## Detection

At scan start, check for:
- `pnpm-workspace.yaml` -- list packages from `packages:` field
- `lerna.json` -- list packages from `packages` field
- `nx.json` -- list projects from `projects` or detect from directory structure
- `turbo.json` -- detect from pipeline configuration
- `rush.json` -- list projects from `projects` field
- Multiple `package.json` files in subdirectories

## If Monorepo Detected

Display this menu:
```
Monorepo detected with N packages:

[1] All packages -- scan entire repo
[2] package-name-1
[3] package-name-2
[4] package-name-3
...
[N+1] Changed packages only -- detect via git diff

Enter selection:
```

## Scoping

If specific packages selected, restrict Grep/Glob to those directories only.

Report findings grouped by package:
```
## Package: @myapp/api
### Finding 1: ...

## Package: @myapp/web
### Finding 2: ...
```

## Shared Dependencies

When scanning specific packages, also check:
- Root `package.json` for shared dependencies (apply to all packages)
- Shared config files (tsconfig.json, .env) at the root level
- Shared utilities imported across packages

## Changed Packages Detection

Run `git diff HEAD --name-only` and map changed files to their owning package based on directory structure.
