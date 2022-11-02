#!/bin/bash

# Get a variable by name and replace URL-encoded characters. Note that the order
# of replacement matters; "%" must be replaced last!
function getvar() {
  grep --only-matching "$1"'=\([^=\&]*\)' \
  | sed 's/'"$1"'=\([^=\&]*\)/\1/' \
  | sed 's/%3[Dd]/=/g' \
  | sed 's/%26/\&/g' \
  | sed 's/%25/%/g'
}

DURATION="$(getvar duration)"
if [ -z "$DURATION" ]; then
  DURATION=5
fi

ffmpeg \
  -hide_banner -loglevel error \
  -y \
  -filter_complex "mandelbrot=size=640x360[v]" \
  -map "[v]" \
  -pix_fmt yuv420p \
  -movflags frag_keyframe+empty_moov \
  -f mp4 \
  -t "$DURATION" \
  -