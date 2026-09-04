# NQType Libraries Agent Protocol

Work from the canonical root `/home/soulxlight/Documents/NQType-Libraries`.

## Ownership

This workspace owns NauqType-native library modules, library API design,
examples, documentation, and library-specific verification.

The separate repository `/home/soulxlight/Documents/NauqType` owns the
language, compiler, runtime, builtins, workspace resolution, and upstream
release contracts. Do not implement or repair those upstream surfaces from
this repository.

## Startup

1. Load and follow the `$nauqtype-work` skill, then read
   `/home/soulxlight/Documents/NauqType/NAUQTYPE_COORDINATION.md`.
2. Read `README.md`.
3. Read the upstream coordination request at
   `/home/soulxlight/Documents/NauqType/NQTYPE_LIBRARIES_NEEDS.md` and any
   linked upstream response.
4. Preserve unrelated changes and inspect repository status before editing.
5. Keep APIs experimental while an upstream dependency is marked provisional.

## Initial Scope

The first intended tranche is pure text/UTF-8/integer/path support followed by
stdio, environment, filesystem, and CLI modules over upstream-owned M54
primitives. Process/time, generic collections, full JSON, FFI, networking, and
concurrency remain later work unless the user changes scope.
