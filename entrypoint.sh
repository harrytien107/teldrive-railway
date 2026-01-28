#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-/tmp}"
mkdir -p "$DATA_DIR"

TELDRIVE_CONFIG_PATH="${TELDRIVE_CONFIG_PATH:-$DATA_DIR/config.toml}"
RCLONE_CONFIG_PATH="${RCLONE_CONFIG_PATH:-$DATA_DIR/rclone.conf}"

# Decode configs
if [[ -n "${TELDRIVE_CONFIG_B64:-}" ]]; then
  echo "$TELDRIVE_CONFIG_B64" | base64 -d > "$TELDRIVE_CONFIG_PATH"
fi
if [[ -n "${RCLONE_CONF_B64:-}" ]]; then
  echo "$RCLONE_CONF_B64" | base64 -d > "$RCLONE_CONFIG_PATH"
fi

test -s "$TELDRIVE_CONFIG_PATH" || { echo "❌ Missing config.toml"; exit 1; }
test -s "$RCLONE_CONFIG_PATH"  || { echo "❌ Missing rclone.conf"; exit 1; }

export RCLONE_CONFIG="$RCLONE_CONFIG_PATH"

echo "🚀 Starting teldrive (run)..."
teldrive run -c "$TELDRIVE_CONFIG_PATH" >"$DATA_DIR/teldrive.log" 2>&1 &
TELDRIVE_PID=$!

sleep 1
if ! kill -0 "$TELDRIVE_PID" 2>/dev/null; then
  echo "❌ teldrive exited immediately. Logs:"
  tail -n 200 "$DATA_DIR/teldrive.log" || true
  exit 1
fi

echo "⏳ Waiting for teldrive on 127.0.0.1:8080 ..."
for i in {1..60}; do
  if curl -fsS "http://127.0.0.1:8080/api/auth/session" >/dev/null 2>&1; then
    echo "✅ teldrive is reachable"
    break
  fi

  if ! kill -0 "$TELDRIVE_PID" 2>/dev/null; then
    echo "❌ teldrive crashed during startup. Logs:"
    tail -n 200 "$DATA_DIR/teldrive.log" || true
    exit 1
  fi

  sleep 1
done

if ! curl -fsS "http://127.0.0.1:8080/api/auth/session" >/dev/null 2>&1; then
  echo "❌ teldrive did not become reachable. Logs:"
  tail -n 200 "$DATA_DIR/teldrive.log" || true
  exit 1
fi

RCLONE_CMD="${RCLONE_CMD:-rclone copy --update --ignore-existing 'pgs:/TheGdriveXbot' 'teldrive:/TheGdriveXbot' -v}"
echo "▶ Running: $RCLONE_CMD"
bash -lc "$RCLONE_CMD"

echo "✅ Job finished"
