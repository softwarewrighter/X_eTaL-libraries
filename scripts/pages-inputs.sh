#!/usr/bin/env bash
# The fingerprint of what pages/ is built from: the libraries, the site,
# the known-good X_eTaL commit. pages/INPUTS records it at build time, and
# scripts/check-pages.sh compares, so a stale pages/ fails the gate.
#   scripts/pages-inputs.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
{
  cat XETAL_COMMIT
  git ls-files -co --exclude-standard libs site images/xetal-logo.jpg \
    | grep -v '\.tdb' | grep -v '/tests/' | sort | while read -r f; do shasum "$f"; done
} | shasum | cut -d' ' -f1
