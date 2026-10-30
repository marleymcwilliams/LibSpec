#!/usr/bin/env bash
# The frozen build outputs, reached through paths outside .lake, for the exports' LEAN_PATH
# (guide/EXECUTABLE_GATE.md §4).
#
# A build in Comparator's sandbox can write all of .lake. It can't change the frozen outputs, but
# it can rename the directories above them and put a substitute in their place. So the exports
# don't reach the frozen outputs through .lake. Each one is bind-mounted read-only at
# TRUSTED_DIR/<package>, outside .lake, where Landlock makes it read-only too. A bind mount keeps
# pointing at the directory it was made from, wherever its parents are moved.
#
# usage: bash scripts/pilot-trusted-lib.sh mount FROZEN_LIST TRUSTED_DIR
#        bash scripts/pilot-trusted-lib.sh unmount TRUSTED_DIR
# FROZEN_LIST lists build directories, .../.lake/packages/<package>/.lake/build, one per line.
set -euo pipefail

case "$1" in
  mount)
    list="$2"
    dir="$3"
    mkdir -p "$dir"
    while IFS= read -r d; do
      pkg="$(basename "$(dirname "$(dirname "$d")")")"
      mkdir -p "$dir/$pkg"
      sudo mount --bind "$d" "$dir/$pkg"
      sudo mount -o remount,bind,ro "$dir/$pkg"
      echo "mounted: $pkg's build outputs, read-only, at $dir/$pkg"
    done < "$list"
    ;;
  unmount)
    dir="$2"
    [ -d "$dir" ] || exit 0
    for m in "$dir"/*; do
      if mountpoint -q "$m"; then sudo umount "$m"; fi
    done
    ;;
  *)
    echo "usage: $0 mount FROZEN_LIST TRUSTED_DIR | unmount TRUSTED_DIR"
    exit 1
    ;;
esac
