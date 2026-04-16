#!/bin/bash
set -e

# 古い server.pid が残っていると起動できないため削除
rm -f /app/tmp/pids/server.pid

exec "$@"
