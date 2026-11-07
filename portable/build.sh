#!/bin/zsh
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
bash "$root/scripts/prepare-framework.sh"
cmake -S "$root" -B "$root/build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DSNESRECOMP_BUILD_VERSION=0.1.1 -DCMAKE_OSX_DEPLOYMENT_TARGET=26.0 -DCMAKE_DISABLE_FIND_PACKAGE_Freetype=ON -DSNESRECOMP_SDL_BACKEND=SDL2 -DSNESRECOMP_ENABLE_NET=OFF -DSNESRECOMP_STATIC_RUNTIME=ON -DRECOMP_UI_ROOT="$root/recomp-ui"
cmake --build "$root/build" -j 6
python3 "$root/portable/package.py"
