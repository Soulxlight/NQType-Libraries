# `std::num`

`std::num` provides deterministic base-10 conversion for the two signed
integer types available in Nauqtype's current core.

## Parsing

- `parse_i32(value: str) -> result<i32, NqParseIntError>`
- `parse_i64(value: str) -> result<i64, NqParseIntError>`

Both functions consume the complete byte string. They accept ASCII digits and
one optional leading `+` or `-`; they reject whitespace, separators, prefixes,
and trailing data. Overflow is checked before each arithmetic step, including
the asymmetric minimum values `-2147483648` and `-9223372036854775808`.

`NqParseIntError` has four public variants:

- `ParseEmpty`
- `ParseSignOnly`
- `ParseInvalidDigit(i32)`
- `ParseOverflow(i32)`

The payload is the zero-based byte index of the first offending digit or byte.
`parse_error_index(error: NqParseIntError) -> option<i32>` returns that payload,
or `None` for empty/sign-only input.

## Rendering

- `i32_to_decimal(value: i32) -> str`
- `i64_to_decimal(value: i64) -> str`

Rendering is canonical: zero is `"0"`, negative values have one leading minus,
and there are no leading zeroes. The implementation keeps the working
magnitude negative, so the minimum signed values never need an overflowing
positive counterpart.
