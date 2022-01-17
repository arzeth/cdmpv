#!/bin/bash
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR"/config.sh
source "$DIR"/createShaders.sh

mkdir -p "$MPV__SHADER_CACHE"
mpv \
--config-dir="$DIR/mpvcfg" \
--input-conf="$DIR/mpvcfg/input.conf" \
--gpu-shader-cache-dir="$MPV__SHADER_CACHE" \
$@
