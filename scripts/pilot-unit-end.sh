#!/usr/bin/env bash
# Records how a challenge's unit ended (guide/EXECUTABLE_GATE.md §4). scripts/pilot-shard.sh gives
# it to the systemd-run wrapper as ExecStopPost, so systemd runs it once the unit's main process
# has gone, whichever way it went: a clean exit, the memory limit, or the time limit.
#
# SERVICE_RESULT, EXIT_CODE and EXIT_STATUS are systemd's. memory.peak and memory.events are the
# kernel's, for the unit's own cgroup. memory.peak counts page cache, which the kernel reclaims
# before it kills anything, so a high peak alone doesn't mean the unit ran out of memory; the
# oom_kill count and SERVICE_RESULT=oom-kill do. This runs outside Comparator's sandbox, so
# nothing the release builds can write the file or choose its values.
#
# usage: pilot-unit-end.sh FILE
cgroup="/sys/fs/cgroup$(cut -d: -f3 /proc/self/cgroup)"
peak="$(cat "$cgroup/memory.peak" 2> /dev/null)"
kills="$(sed -n 's/^oom_kill //p' "$cgroup/memory.events" 2> /dev/null)"
printf 'result=%s code=%s status=%s peak_bytes=%s oom_kills=%s\n' \
  "${SERVICE_RESULT:--}" "${EXIT_CODE:--}" "${EXIT_STATUS:--}" "${peak:--}" "${kills:--}" > "$1"
