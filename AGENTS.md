# NQType Libraries Agent Protocol

Work from this repository's canonical checkout. (The golden repositories
migrated from a retired Linux host to the primary Windows workstation on
2026-09-19; machine-local canonical paths are recorded in the local
`$nauqtype-work` skill, and the upstream coordination ledger carries the
"Host Migration" section.)

## Lead Ownership

Rāchül (Kimi Code) owns this repository's development as of 2026-09-19:
planning, module APIs, examples, docs, library tests, reviews, commits, and
pushes. Codex agents may be assigned library work, but they operate under
Rāchül's coordination: they receive a bounded task with an explicit write
set, do not commit or push independently, and hand off findings, files
changed, and checks run for Rāchül to review and land. The upstream
NauqType compiler/runtime repository remains Codex-owned.

## Ownership

This workspace owns NauqType-native library modules, library API design,
examples, documentation, and library-specific verification.

The separate NauqType compiler/runtime repository owns the language,
compiler, runtime, builtins, workspace resolution, and upstream release
contracts. Do not implement or repair those upstream surfaces from this
repository.

## Startup

1. Load and follow the `$nauqtype-work` skill, then read
   `NAUQTYPE_COORDINATION.md` in the canonical NauqType compiler checkout
   (the skill records its machine-local path).
2. Read `README.md`.
3. Read the upstream coordination request `NQTYPE_LIBRARIES_NEEDS.md` in the
   NauqType compiler checkout and any linked upstream response.
4. Preserve unrelated changes and inspect repository status before editing.
5. Keep APIs experimental while an upstream dependency is marked provisional.

## Initial Scope

The first intended tranche is pure text/UTF-8/integer/path support followed by
stdio, environment, filesystem, and CLI modules over upstream-owned M54
primitives. Process/time, generic collections, full JSON, FFI, networking, and
concurrency remain later work unless the user changes scope.
