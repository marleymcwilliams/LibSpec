#!/usr/bin/env bash
# Gives the runner exactly GB gigabytes of swap, for the shard job's swap_gb input and the
# self-test (guide/EXECUTABLE_GATE.md §4). It logs `free -h` and `swapon --show` before and after.
# Any swap the runner already has is reported and turned off first, so the runner's swap is the
# one swapfile made here, and a run's swap is what its input says. With 0 it changes nothing: the
# challenges' units then get MemorySwapMax=0, so the runner's own swap never reaches them.
#
# It refuses unless / keeps 40 GB free besides the swapfile: a solo shard's build took about 24 GB
# of / in run 42540237805, which had 104 GB free after the job freed disk space.
#
# usage: bash scripts/pilot-swap.sh GB
set -euo pipefail

gb="$1"
spare_gb=40
file=/pilot.swap
[[ "$gb" =~ ^(0|[1-9][0-9]?)$ ]] || { echo "FAIL: swap_gb must be a whole number from 0 to 99"; exit 1; }

echo "before:"
free -h
swapon --show
existing_mb=$(($(awk '/^SwapTotal:/ {print $2}' /proc/meminfo) / 1024))
echo "the runner has $existing_mb MB of swap of its own"
if [ "$gb" -eq 0 ]; then
  echo "swap: none added. The challenges' units get MemorySwapMax=0, so the runner's own swap doesn't reach them"
  exit 0
fi

avail_mb="$(df -BM --output=avail / | tail -n 1 | tr -dc '0-9')"
need_mb=$(((gb + spare_gb) * 1024))
[ "$avail_mb" -ge "$need_mb" ] ||
  { echo "FAIL: a ${gb} GB swapfile needs $need_mb MB free on /, with $spare_gb GB left for the build; there are $avail_mb MB"; exit 1; }

if [ "$existing_mb" -gt 0 ]; then
  mapfile -t old < <(swapon --show=NAME,TYPE --noheadings | awk '$2 == "file" {print $1}')
  sudo swapoff -a
  for f in ${old[@]+"${old[@]}"}; do sudo rm -f "$f"; done
  echo "turned off the runner's own $existing_mb MB of swap${old[0]:+, and removed ${old[*]}}"
fi
sudo fallocate -l "${gb}G" "$file"
sudo chmod 600 "$file"
sudo mkswap "$file" > /dev/null
sudo swapon "$file"

echo "after:"
free -h
swapon --show
total_kb="$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)"
# mkswap keeps the first page for its header.
want_kb=$((gb * 1024 * 1024 - 4))
[ "$total_kb" -ge "$want_kb" ] && [ "$total_kb" -le $((gb * 1024 * 1024)) ] ||
  { echo "FAIL: the runner has $total_kb kB of swap, not ${gb} GB"; exit 1; }
echo "ok: the runner has ${gb} GB of swap, all of it $file"
