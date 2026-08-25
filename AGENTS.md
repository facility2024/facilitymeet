# AGENTS.md

Quick-reference for AI agents working in this repo. See `CLAUDE.md` for full architecture docs.

## Setup

- Node >= 24, npm >= 11 (`.nvmrc` pins Node 24)
- `npm install` runs `postinstall` which does `patch-package`, `jetify`, android cmake cleanup, and android autolinking — don't skip it

## Validation (pre-commit)

Run in this order, all must pass with 0 warnings:

```
npm run lint:ci        # ESLint only (no type-check)
npm run tsc:web        # TypeScript check — web platform
npm run tsc:native     # TypeScript check — native platform
```

Single shortcut: `npm run lint:ci && npm run tsc:ci`

Auto-fix lint issues: `npm run lint-fix`

## Dev / Build

- `make dev` — starts webpack-dev-server at `https://localhost:8080/` (self-signed certs, expected warnings)
- `make compile` — production webpack build
- Dev server proxies to `https://alpha.jitsi.net` by default; override with `WEBPACK_DEV_SERVER_PROXY_TARGET`

## Testing

WebDriverIO end-to-end tests (not unit tests):

```
npm run test-single -- <spec-file>   # single test
npm run test-dev-single -- <spec-file>  # single test against dev server
```

Full suite: `npm test`. Env loaded from `tests/.env`.

## Platform-specific file conventions

Edit the right file variant — this is the most common mistake:

- `*.web.ts` / `*.web.tsx` — web-only code
- `*.native.ts` / `*.native.tsx` — React Native-only code
- `*.any.ts` / `*.any.tsx` — shared cross-platform code
- Build excludes wrong-platform files via `moduleSuffixes` in tsconfigs

## Adding a new feature

1. Create `react/features/<feature-name>/` with standard structure (actionTypes, actions, reducer, middleware, etc.)
2. **Register** the feature by importing it into the correct platform file:
   - Middleware: `react/features/app/middlewares.{any,web,native}.ts`
   - Reducer: `react/features/app/reducers.{any,web,native}.ts`
3. Avoid `index.ts` barrel files in features

## Redux pattern

Registry-based architecture — features register themselves, don't combine manually:

- `ReducerRegistry` — features register reducers independently
- `MiddlewareRegistry` — features register middleware independently
- Global state type: `IReduxState` with 80+ feature states

## React version

React **19** (19.2.3), not React 18. `@types/react` pinned to 17.0.14.

## Commit format

Conventional Commits with **mandatory scopes**: `feat(feature-name): description`

## Useful non-obvious commands

- `npx webpack -p --analyze-bundle` then `npx webpack-bundle-analyzer build/app-stats.json` — bundle size analysis
- `npm run lang-sort` — sort language JSON files
- `npm run lint:lang` — validate language JSON files
- `ANALYZE_BUNDLE=true make compile` — generate bundle stats
- `DETECT_CIRCULAR_DEPS=true make compile` — detect circular deps
