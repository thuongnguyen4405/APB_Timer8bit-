#!/usr/bin/env bash
# Installs only SV verification code into the existing project, preserving RTL and original Makefile.
set -euo pipefail
DEST="${1:-$HOME/project_dva/project1}"
HERE="$(cd -- "$(dirname -- "$0")" && pwd)"
if [[ ! -d "$DEST/rtl" ]]; then
  echo "ERROR: expected project root containing RTL directory: $DEST" >&2
  exit 2
fi
if [[ ! -f "$DEST/rtl/timer_top.vp" && ! -f "$DEST/rtl/timer_top.v" ]]; then
  echo "ERROR: missing timer_top.vp (protected) or timer_top.v under $DEST/rtl" >&2
  exit 2
fi
NOW="$(date +%Y%m%d_%H%M%S)"
BACKUP="$DEST/backup_before_timer_dv_${NOW}"
mkdir -p "$BACKUP/tb" "$BACKUP/testcase" "$BACKUP/sim"
for dir in tb testcase; do
  for p in "$HERE/$dir"/*.sv; do
    name="$(basename "$p")"
    if [[ -e "$DEST/$dir/$name" ]]; then
      cp -p "$DEST/$dir/$name" "$BACKUP/$dir/$name"
    fi
    cp -p "$p" "$DEST/$dir/$name"
  done
done
for name in compile.f rtl.f tb.f regress.cfg; do
  if [[ -e "$DEST/sim/$name" ]]; then cp -p "$DEST/sim/$name" "$BACKUP/sim/$name"; fi
  cp -p "$HERE/sim/$name" "$DEST/sim/$name"
done
for name in Makefile.dv regress.py; do
  cp -p "$HERE/sim/$name" "$DEST/sim/$name"
done
# Screenshot uses encrypted .vp at top; adapt only when an unprotected .v exists.
if [[ ! -f "$DEST/rtl/timer_top.vp" && -f "$DEST/rtl/timer_top.v" ]]; then
  sed -i 's@../rtl/timer_top\.vp@../rtl/timer_top.v@' "$DEST/sim/rtl.f"
fi
mkdir -p "$DEST/docs"
cp -p "$HERE/docs/"*.md "$DEST/docs/"
echo "Installed non-UVM DV environment into: $DEST"
echo "Original files backup: $BACKUP"
echo "Protected RTL and original Makefile/regress.pl NOT modified."
echo "Next: cd '$DEST/sim'; make -f Makefile.dv build"
