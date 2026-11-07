#!/usr/bin/env bash
# Render actual X_eTaL RGB output; optionally record the SVGs for the site.
set -euo pipefail
preview_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$preview_root"
preview_out="$preview_root/work/scene-previews"
mkdir -p "$preview_out"
for preview_target in Scene/logo Extrusion/logo RayTrace/diagnostic Glass/example Glass/lens-area; do
  preview_library="${preview_target%/*}"
  preview_demo="${preview_target#*/}"
  preview_name="$preview_library-$preview_demo"
  printf 'rendering %s\n' "$preview_target"
  "$preview_root/scripts/xt" run "libs/$preview_library/demos/$preview_demo.xtl" >"$preview_out/$preview_name.out" 2>"$preview_out/$preview_name.err"
  cp "$preview_root/work/draw/$preview_demo-1.svg" "$preview_out/$preview_name.svg"
  if [ "${1:-}" = --record ]; then
    cp "$preview_out/$preview_name.svg" "libs/$preview_library/docs/preview-$preview_demo.svg"
  fi
  if command -v rsvg-convert >/dev/null; then
    rsvg-convert -o "$preview_out/$preview_name.png" "$preview_out/$preview_name.svg"
  fi
  printf '%s\n' "$preview_out/$preview_name.svg"
done
