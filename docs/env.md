# `std::env`

`std::env` exposes program arguments, environment values, and the current
working directory over the frozen M54 authority primitives. Every function
declares `effects(io)`.

## Arguments

- `program_argument() -> option<str>` returns OS argument zero when present.
- `argument_count() -> i32` counts user arguments and excludes argument zero.
- `argument_at(index: i32) -> option<str>` indexes only user arguments, so
  index zero is the first value after the program argument. Negative and
  out-of-range indexes return `None`.
- `arguments() -> list<str>` collects those user arguments into an owned list.

Arguments remain byte strings and are not implicitly interpreted as UTF-8 or
paths.

## Environment and directory

- `environment_get(name: str) -> result<option<str>, io_err>` distinguishes an
  absent variable (`Ok(None)`) from a present empty value (`Ok(Some(""))`).
- `working_directory() -> result<str, io_err>` returns the absolute current
  directory reported by Linux.

Environment values and the returned directory remain unvalidated byte strings.
Use `std::utf8` only where the application explicitly requires text. Embedded
NUL in an OS-bound name is rejected upstream as `io_err` kind `invalid_input`;
it is never truncated.
