#!/bin/bash
echo "=== our stale Connect.jar (bb_root_*) ==="
pgrep -af "Connect.jar" | grep -F "bb_root_"
for pid in $(pgrep -af "Connect.jar" | grep -F "bb_root_" | awk '{print $1}'); do
  echo "killing ours: $pid"
  kill "$pid" 2>/dev/null
done
sleep 4
echo "=== 22 / 4455 ==="
(timeout 3 bash -c 'echo >/dev/tcp/169.254.0.1/22') 2>/dev/null && echo "22 OPEN" || echo "22 closed"
(timeout 3 bash -c 'echo >/dev/tcp/169.254.0.1/4455') 2>/dev/null && echo "4455 OPEN" || echo "4455 closed"
