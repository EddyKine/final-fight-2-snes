#!/bin/sh
set -eu
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
export SNESRECOMP_BEAM_ASYNC_INTERRUPTS=1
export SNESRECOMP_BEAM_LIVE_RASTER=1
export SNESRECOMP_BEAM_SCANOUT_CLOCK=512
cd "$root/build"
exec ./FinalFight2SNESRecomp "$@"
