#!/bin/sh
set -eu
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$root"
expected=5ac4b98e065b668ed77b65fa6342ec296b8b9e23
actual=$(git -C snesrecomp rev-parse HEAD)
[ "$actual" = "$expected" ] || { echo "Unexpected snesrecomp revision: $actual" >&2; exit 1; }
patch="$root/patches/snesrecomp-finalfight2.patch"
if git -C snesrecomp apply --reverse --check "$patch" 2>/dev/null; then
 echo "Final Fight 2 framework patch already applied."
else
 git -C snesrecomp apply --check "$patch"
 git -C snesrecomp apply "$patch"
 echo "Final Fight 2 framework patch applied."
fi
