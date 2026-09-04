# Library verification

`core/` is an ordinary locked consumer workspace. Its dependency path points
to the repository root as `nauqtype.std`, so it exercises the same package and
cross-workspace contracts as a vendored consumer without checking in a second
copy of the library sources.

`core/src/main.nq` returns zero only when the text, UTF-8, numeric, and lexical
path behavior checks pass. Nonzero codes below 40 identify text checks, codes
from 41 through 89 identify UTF-8 checks, codes from 91 through 129 identify
numeric checks, and codes from 131 upward identify path checks.
It imports all six modules together so duplicate public names or nominal-type
collisions fail during checking even though authority calls live in a separate
executable.

`core/src/authority.nq` exercises the argument, environment, cwd, and text
stream wrappers. `core/src/binary.nq` round-trips arbitrary bytes through both
standard output and standard error. The verification script drives these
executables with controlled arguments, environment values, working directory,
stdin, and byte-exact output assertions; it also checks their facts and review
evidence.

Run the complete local gate with `scripts/check.sh`. A source edit changes the
locked dependency hash; update `core/nauqtype.workspace.lock.json` deliberately
after reviewing the source change rather than teaching the test to refresh its
own authority record.
