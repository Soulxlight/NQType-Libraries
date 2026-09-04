#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ -n "${NAUQC:-}" ]; then
    compiler=$NAUQC
elif [ -x "$repo_root/../NauqType/bin/nauqc" ]; then
    compiler=$repo_root/../NauqType/bin/nauqc
elif command -v nauqc >/dev/null 2>&1; then
    compiler=$(command -v nauqc)
else
    echo "nauqc not found; set NAUQC=/path/to/nauqc" >&2
    exit 2
fi

verify_root=$(mktemp -d "${TMPDIR:-/tmp}/nqtype-libraries-check.XXXXXX")
trap 'rm -rf "$verify_root"' EXIT HUP INT TERM

cd "$repo_root"

for source in \
    src/text.nq \
    src/utf8.nq \
    src/num.nq \
    src/path.nq \
    src/stdio.nq \
    src/env.nq \
    tests/core/src/main.nq \
    tests/core/src/authority.nq \
    tests/core/src/binary.nq
do
    "$compiler" check "$source"
    "$compiler" fmt --check "$source"
done

copied_root=$verify_root/NQType-Libraries
mkdir -p "$copied_root/src" "$copied_root/tests/core/src"
cp nauqtype.workspace.json "$copied_root/nauqtype.workspace.json"
cp src/text.nq src/utf8.nq src/num.nq src/path.nq src/stdio.nq src/env.nq "$copied_root/src/"
cp tests/core/nauqtype.workspace.json tests/core/nauqtype.workspace.lock.json "$copied_root/tests/core/"
cp tests/core/src/main.nq tests/core/src/authority.nq tests/core/src/binary.nq "$copied_root/tests/core/src/"

core_source=$copied_root/tests/core/src/main.nq
authority_source=$copied_root/tests/core/src/authority.nq
binary_source=$copied_root/tests/core/src/binary.nq

"$compiler" facts "$core_source" --format v3 > "$verify_root/core-facts.json"
"$compiler" review "$core_source" --format v2 > "$verify_root/core-review.json"
"$compiler" facts "$authority_source" --format v3 > "$verify_root/authority-facts.json"
"$compiler" review "$authority_source" --format v2 > "$verify_root/authority-review.json"
"$compiler" build "$core_source" -o "$verify_root/core-tests"
"$compiler" build "$authority_source" -o "$verify_root/authority-tests"
"$compiler" build "$binary_source" -o "$verify_root/binary-tests"
"$verify_root/core-tests"
"$compiler" run "$core_source" -o "$verify_root/core-tests-run"

python3 - \
    "$verify_root/core-facts.json" \
    "$verify_root/authority-facts.json" \
    "$verify_root/core-review.json" \
    "$verify_root/authority-review.json" \
    "$verify_root/authority-tests" \
    "$verify_root/binary-tests" \
    "$verify_root/runtime-cwd" <<'PY'
import json
import os
import subprocess
import sys
from pathlib import Path

with open(sys.argv[1], encoding="utf-8") as handle:
    core_facts = json.load(handle)
with open(sys.argv[2], encoding="utf-8") as handle:
    authority_facts = json.load(handle)
with open(sys.argv[3], encoding="utf-8") as handle:
    core_review = json.load(handle)
with open(sys.argv[4], encoding="utf-8") as handle:
    authority_review = json.load(handle)

for facts in (core_facts, authority_facts):
    assert facts["version"] == 3
    assert facts["workspace"]["name"] == "nauqtype.std.core_tests"
    dependency = facts["dependencies"][0]
    assert dependency["alias"] == "std"
    assert dependency["workspace"] == "nauqtype.std"

export_ids = {
    entry["id"]
    for facts in (core_facts, authority_facts)
    for entry in facts["exports"]
}
for required in (
    "workspace:nauqtype.std::module:text::fn:split_literal",
    "workspace:nauqtype.std::module:utf8::type:NqUtf8Step",
    "workspace:nauqtype.std::module:utf8::enum:NqUtf8Error",
    "workspace:nauqtype.std::module:num::enum:NqParseIntError",
    "workspace:nauqtype.std::module:num::fn:parse_i64",
    "workspace:nauqtype.std::module:path::fn:path_normalize",
    "workspace:nauqtype.std::module:stdio::fn:read_stdin_bytes",
    "workspace:nauqtype.std::module:stdio::fn:write_stdout_line",
    "workspace:nauqtype.std::module:env::fn:arguments",
    "workspace:nauqtype.std::module:env::fn:working_directory",
):
    assert required in export_ids, required

core_functions = {
    entry["qualified_name"]: entry
    for entry in core_review["functions"]
}
path_normalize = core_functions["std::path::path_normalize"]
assert path_normalize["audit"]["effects"] == []
assert path_normalize["inferred"]["effects"] == []
assert path_normalize["evidence"] == {"audit": "declared", "inferred": "checked"}

functions = {
    entry["qualified_name"]: entry
    for entry in authority_review["functions"]
}
expected_io = {
    "std::env::argument_count": ["arguments"],
    "std::env::environment_get": ["environment"],
    "std::env::working_directory": ["cwd"],
    "std::stdio::read_stdin": ["stdin"],
    "std::stdio::write_stdout_line": ["stdout"],
    "std::stdio::write_stderr_line": ["stderr"],
}
for name, kinds in expected_io.items():
    function = functions[name]
    assert function["audit"]["effects"] == ["io"], name
    assert function["inferred"]["effects"] == ["io"], name
    assert function["inferred"]["io_kinds"] == kinds, name
    assert function["evidence"] == {"audit": "declared", "inferred": "checked"}, name

authority_executable = sys.argv[5]
binary_executable = sys.argv[6]
runtime_cwd = Path(sys.argv[7])
runtime_cwd.mkdir()

environment = os.environ.copy()
environment["NQTYPE_LIB_PRESENT"] = "present-value"
environment["NQTYPE_LIB_EMPTY"] = ""
environment["NQTYPE_LIB_EXPECTED_CWD"] = str(runtime_cwd)
environment.pop("NQTYPE_LIB_INTENTIONALLY_MISSING_7A93", None)

authority = subprocess.run(
    [authority_executable, "probe", "alpha", "beta"],
    input=b"first\nsecond",
    cwd=runtime_cwd,
    env=environment,
    capture_output=True,
)
assert authority.returncode == 0, (authority.returncode, authority.stdout, authority.stderr)
assert authority.stdout == b"out:first\nsecond", authority.stdout
assert authority.stderr == b"err\n", authority.stderr

no_arguments = subprocess.run(
    [authority_executable],
    input=b"",
    cwd=runtime_cwd,
    env=environment,
    capture_output=True,
)
assert no_arguments.returncode == 0, (
    no_arguments.returncode,
    no_arguments.stdout,
    no_arguments.stderr,
)
assert no_arguments.stdout == b"", no_arguments.stdout
assert no_arguments.stderr == b"", no_arguments.stderr

crlf = subprocess.run(
    [authority_executable, "probe", "alpha", "beta"],
    input=b"first\r\nsecond",
    cwd=runtime_cwd,
    env=environment,
    capture_output=True,
)
assert crlf.returncode == 0, (crlf.returncode, crlf.stdout, crlf.stderr)
assert crlf.stdout == b"out:first\r\nsecond", crlf.stdout
assert crlf.stderr == b"err\n", crlf.stderr

payload = b"\x00\xffNauqtype\n\x80"
binary = subprocess.run(
    [binary_executable],
    input=payload,
    cwd=runtime_cwd,
    capture_output=True,
)
assert binary.returncode == 0, (binary.returncode, binary.stdout, binary.stderr)
assert binary.stdout == payload, binary.stdout
assert binary.stderr == payload, binary.stderr
PY

echo "nqtype libraries check ok"
