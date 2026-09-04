# `std::utf8`

`std::utf8` validates and traverses UTF-8 explicitly on top of byte-oriented
`str`. It accepts canonical UTF-8 only: overlong forms, surrogate code points,
values above `U+10FFFF`, stray continuation bytes, truncated sequences, and
bad continuation bytes are errors.

## Types

```nauq
pub type NqUtf8Step {
    code_point: i32,
    next_byte: i32,
}
```

`NqUtf8Step` contains one decoded Unicode scalar value and the byte index at
which the next sequence starts.

`NqUtf8Error` has these public variants, each carrying the relevant index:

- `Utf8ByteIndexOutOfBounds(i32)`
- `Utf8CodePointIndexOutOfBounds(i32)`
- `Utf8UnexpectedContinuation(i32)`
- `Utf8UnexpectedEnd(i32)`
- `Utf8InvalidContinuation(i32)`
- `Utf8OverlongEncoding(i32)`
- `Utf8SurrogateCodePoint(i32)`
- `Utf8CodePointTooLarge(i32)`

Use `utf8_error_index(error: NqUtf8Error) -> i32` when code does not need to
distinguish the variant. For malformed sequences, the index is a byte index;
the code-point bounds variant carries the requested code-point index.

## Functions

- `decode_at(value: str, byte_index: i32) -> result<NqUtf8Step, NqUtf8Error>`
  decodes exactly one sequence starting at a byte boundary.
- `validate(value: str) -> result<unit, NqUtf8Error>` validates the complete
  string.
- `is_valid(value: str) -> bool` is the detail-free validation predicate.
- `code_point_count(value: str) -> result<i32, NqUtf8Error>` validates while
  counting Unicode scalar values.
- `code_point_at(value: str, code_point_index: i32) -> result<i32, NqUtf8Error>`
  returns one scalar value.
- `slice_code_points(value: str, start_index: i32, end_index: i32) -> result<str, NqUtf8Error>`
  converts a half-open code-point range to byte boundaries and returns the
  underlying slice.

`slice_code_points` validates every sequence it traverses to reach the end
index. It does not inspect a suffix beyond that range. This keeps the operation
proportional to the requested prefix and avoids pretending `str` itself is a
validated-text type.

Encoding code points into new strings is intentionally absent: M54 exposes
read-only byte access and `str_from_bytes`, but no mutable byte-builder
primitive. The library will not emulate one with a giant lookup table.
