# `std::path`

`std::path` performs pure lexical operations on Linux paths. `/` is the only
separator; backslash and every other byte are ordinary component data. The
module does not access the filesystem, follow symlinks, establish containment,
or claim that a path names an existing object.

## Inspection

- `path_is_absolute(value: str) -> bool` tests for a leading `/`.
- `path_is_root(value: str) -> bool` accepts one or more `/` bytes and no
  components.
- `path_has_trailing_separator(value: str) -> bool` tests the final byte.
- `path_file_name(value: str) -> option<str>` ignores trailing separators and
  returns the last nonempty component. Empty paths and roots return `None`.
- `path_parent(value: str) -> option<str>` returns a dirname-style parent.
  Roots have no parent; an empty or single-component relative path returns
  `Some(".")`.
- `path_extension(value: str) -> option<str>` returns bytes after the final
  filename dot. A leading dot alone does not create an extension, while a
  trailing dot produces `Some("")`. The special `.` and `..` components have
  no extension.
- `path_stem(value: str) -> option<str>` removes only the final extension and
  preserves a leading-dot filename as well as `.` and `..`.

Inspection does not normalize interior separators. For example, the parent of
`/srv//data/report.txt` is `/srv//data`.

## Composition and normalization

- `path_join(base: str, child: str) -> str` inserts a slash when needed. An
  absolute child replaces the base, and an empty child leaves the base intact.
- `path_components(value: str) -> list<str>` collects nonempty components. It
  removes repeated separators but preserves literal `.` and `..` components.
- `path_normalize(value: str) -> str` collapses repeated separators, removes
  `.`, resolves `..` against a preceding ordinary component, preserves leading
  `..` in relative paths, and prevents `..` from climbing above an absolute
  root. Empty relative results become `.`.
- `path_normalize_join(base: str, child: str) -> str` joins and then applies
  those normalization rules.
- `path_is_normalized(value: str) -> bool` compares a path with that canonical
  lexical form.

Lexical normalization is not a security boundary. In particular, symlinks can
make filesystem resolution differ from the normalized text. OS-facing M54
operations also reject embedded NUL bytes even though these pure functions do
not need to inspect them.
