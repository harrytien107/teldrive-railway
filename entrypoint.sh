#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="/data"
mkdir -p "$DATA_DIR"

TELDRIVE_CONFIG_PATH="$DATA_DIR/config.toml"
RCLONE_CONFIG_PATH="$DATA_DIR/rclone.conf"

# Decode base64 configs
if [[ -n "${TELDRIVE_CONFIG_B64:-}" ]]; then
  echo "$TELDRIVE_CONFIG_B64" | base64 -d > "$TELDRIVE_CONFIG_PATH"
fi

if [[ -n "${RCLONE_CONF_B64:-}" ]]; then
  echo "$RCLONE_CONF_B64" | base64 -d > "$RCLONE_CONFIG_PATH"
fi

# Validate
test -s "$TELDRIVE_CONFIG_PATH" || { echo "❌ Missing config.toml"; exit 1; }
test -s "$RCLONE_CONFIG_PATH"  || { echo "❌ Missing rclone.conf"; exit 1; }

export RCLONE_CONFIG="$RCLONE_CONFIG_PATH"

# Start teldrive
echo "🚀 Starting teldrive..."
teldrive serve --config "$TELDRIVE_CONFIG_PATH" >/tmp/teldrive.log 2>&1 &

sleep 3

# Run rclone
RCLONE_CMD="${RCLONE_CMD:-rclone copy --update --ignore-existing 'pgs:/TheGdriveXbot' 'teldrive:/TheGdriveXbot' -v}"
echo "▶ Running: $RCLONE_CMD"
bash -lc "$RCLONE_CMD"

echo "✅ Job finished"
