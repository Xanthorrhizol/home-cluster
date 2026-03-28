#!/bin/sh
cd /root && \
service cron start && \
exec ttyd \
  --port 7681 \
  --credential "${TTYD_USER}:${TTYD_PASS}" \
  --writable \
  claude
