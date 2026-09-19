# NQType Libraries

Canonical workspace: machine-local; recorded in the local `$nauqtype-work`
skill. (The golden repositories migrated from a retired Linux host to the
primary Windows workstation on 2026-09-19; GitHub
`Soulxlight/NQType-Libraries` is the sync remote.)

This repository owns reusable Nauqtype-native libraries, their public APIs,
library examples, documentation, and library-specific tests. It does not own
the NauqType language, compiler, runtime, builtin contracts, workspace
resolver, or upstream release machinery.

## Status

The first six experimental foundation modules are implemented against the
frozen M54 upstream contract:

| Import | Purpose | API notes |
| --- | --- | --- |
| `std::text` | Byte-oriented search, trimming, splitting, joining, and replacement | [Text API](docs/text.md) |
| `std::utf8` | Explicit UTF-8 validation, decoding, traversal, and code-point slicing | [UTF-8 API](docs/utf8.md) |
| `std::num` | Checked decimal parsing and full-range decimal rendering for `i32` and `i64` | [Number API](docs/num.md) |
| `std::path` | Pure lexical Linux path inspection, joining, components, and normalization | [Path API](docs/path.md) |
| `std::stdio` | Checked standard-input, standard-output, and standard-error wrappers | [Standard IO API](docs/stdio.md) |
| `std::env` | Program arguments, environment lookup, and current-directory access | [Environment API](docs/env.md) |

These APIs are experimental while Nauqtype is in alpha. M54 freezes the
language/runtime contracts they rely on, but compiler-bundled library
resolution and a semantic package-version field remain deferred. Consumers
therefore use an explicit locked path dependency.

The six-module foundation is published for exact-revision Git consumption.
Consumers should pin a commit and its matching lock hashes; the project does
not yet promise semantic package versions or a stable alpha API.

## Consume the library

Vendor this repository at `vendor/std`, then declare it explicitly:

```json
{
  "version": "workspace/v1",
  "workspace": {
    "name": "example.tool",
    "source_roots": ["src"]
  },
  "dependencies": [
    {
      "alias": "std",
      "path": "vendor/std",
      "workspace": "nauqtype.std"
    }
  ]
}
```

The matching `nauqtype.workspace.lock.json` must contain the dependency
manifest and source hashes required by `workspace-lock/v1`. Imports remain
visible in source:

```nauq
use std::num as num;
use std::text as text;
use std::utf8 as utf8;

fn main() -> i32 {
    if text::contains("Nauqtype", "type") {
        match num::parse_i32("42") {
            Ok(value) => {
                if value == 42 { return 0; }
                return 1;
            },
            Err(_) => { return 1; },
        }
    }
    return 2;
}
```

`str` is an immutable byte string and is not implicitly UTF-8. The `text`
module deliberately stays byte-oriented; Unicode behavior is explicit through
`utf8`.

## Verify

With the upstream checkout beside this repository:

```bash
scripts/check.sh
```

Or select a compiler explicitly:

```bash
NAUQC=/path/to/nauqc scripts/check.sh
```

The gate checks every library module without an entrypoint, checks formatting,
copies and loads the locked consumer workspace, emits facts v3 and review v2,
verifies checked IO evidence, builds the native test executables, exercises
arguments/environment/cwd, and round-trips arbitrary bytes through both output
streams. The pure test executable runs through both `build` and `run`.

## Ownership boundary

Upstream compiler/runtime repository: the canonical NauqType checkout
(machine-local path recorded in the `$nauqtype-work` skill).

The coordination request and frozen response live in that checkout as:

- `NQTYPE_LIBRARIES_NEEDS.md`
- `NQTYPE_LIBRARIES_UPSTREAM_RESPONSE.md`

This repository does not modify upstream language, compiler, runtime,
resolver, or release surfaces.
