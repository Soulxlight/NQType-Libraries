# `std::text`

`std::text` provides pure helpers over Nauqtype's immutable, byte-indexed
`str`. It never claims that input is UTF-8 and never changes or replaces
non-ASCII bytes.

## Byte access

- `byte_len(value: str) -> i32` returns the byte length.
- `byte_at(value: str, byte_index: i32) -> option<i32>` returns a byte in the
  range `0..255`, or `None` out of bounds.
- `byte_slice(value: str, start_byte: i32, end_byte: i32) -> option<str>` uses
  a half-open byte range. It does not require UTF-8 boundaries.

## Literal search

- `starts_with(value: str, prefix: str) -> bool`
- `ends_with(value: str, suffix: str) -> bool`
- `contains(value: str, pattern: str) -> bool`
- `find(value: str, pattern: str) -> option<i32>`
- `find_from(value: str, pattern: str, start_byte: i32) -> option<i32>`
- `rfind(value: str, pattern: str) -> option<i32>`

Search results are byte indexes. A negative `find_from` start is clamped to
zero. An empty pattern is found at the selected start; `rfind` finds it at the
end of the string.

## Transformation

- `strip_prefix(value: str, prefix: str) -> option<str>`
- `strip_suffix(value: str, suffix: str) -> option<str>`
- `trim_ascii_start(value: str) -> str`
- `trim_ascii_end(value: str) -> str`
- `trim_ascii(value: str) -> str`
- `split_literal(value: str, separator: str) -> list<str>`
- `join(parts: ref list<str>, separator: str) -> str`
- `replace_all(value: str, pattern: str, replacement: str) -> str`

ASCII trimming recognizes bytes `0x09` through `0x0d` and `0x20` only.
`split_literal` uses non-overlapping matches and preserves leading, interior,
and trailing empty fields. An empty separator produces one field containing
the original value. `replace_all` likewise leaves the value unchanged when
its pattern is empty.

The current implementation favors a small pure-Nauqtype surface over a hidden
runtime string builder. Repeated concatenation can be quadratic for large
inputs; a future builder should be introduced as an explicit library/runtime
contract rather than silently changing ownership behavior.
