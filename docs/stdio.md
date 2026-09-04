# `std::stdio`

`std::stdio` gives the frozen M54 stream primitives consistent library names
and a pair of line-writing conveniences. Every function declares
`effects(io)` and retains the primitive's `io_err` without translating or
hiding it.

## Input

- `read_stdin() -> result<str, io_err>` reads all remaining input into an
  unvalidated byte string.
- `read_stdin_bytes() -> result<bytes, io_err>` reads all remaining input into
  an owned, move-only byte buffer.
- `read_stdin_line() -> result<option<str>, io_err>` reads one line, removes
  one trailing line-feed, preserves every other byte, and returns `None` only
  when EOF occurs before any byte.

The `str`-returning operations do not validate UTF-8. Pass their values to
`std::utf8` when a caller requires validated text.

## Output

- `write_stdout(value: str) -> result<unit, io_err>`
- `write_stdout_bytes(value: ref bytes) -> result<unit, io_err>`
- `write_stdout_line(value: str) -> result<unit, io_err>`
- `flush_stdout() -> result<unit, io_err>`
- `write_stderr(value: str) -> result<unit, io_err>`
- `write_stderr_bytes(value: ref bytes) -> result<unit, io_err>`
- `write_stderr_line(value: str) -> result<unit, io_err>`
- `flush_stderr() -> result<unit, io_err>`

Raw writes add nothing. Line writes append exactly one `0x0a` byte. Neither
form flushes implicitly, and borrowed byte buffers are never consumed or
retained.

Code requiring delivery evidence must check both its write and the matching
flush. In particular, a `broken_pipe` error may surface at either boundary
because M54 output is buffered.
