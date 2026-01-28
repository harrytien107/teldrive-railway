#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-/data}"
mkdir -p "$DATA_DIR"

TELDRIVE_CONF_PATH="${TELDRIVE_CONF_PATH:-$DATA_DIR/teldrive.conf}"
RCLONE_CONF_PATH="${RCLONE_CONF_PATH:-$DATA_DIR/rclone.conf}"

# Khuyên dùng base64 để khỏi vỡ format multiline khi paste vào Railway Variables
if [[ -n "${TELDRIVE_CONF_B64:-}" ]]; then
  echo "$TELDRIVE_CONF_B64" | base64 -d > "$TELDRIVE_CONF_PATH"
fi
if [[ -n "${RCLONE_CONF_B64:-}" ]]; then
  echo "$RCLONE_CONF_B64" | base64 -d > "$RCLONE_CONF_PATH"
fi

# Validate
test -s "$TELDRIVE_CONF_PATH" || { echo "Missing teldrive config at $TELDRIVE_CONF_PATH"; exit 1; }
test -s "$RCLONE_CONF_PATH"  || { echo "Missing rclone config at $RCLONE_CONF_PATH"; exit 1; }

export TELDRIVE_CONFIG="$TELDRIVE_CONF_PATH"
export RCLONE_CONFIG="$RCLONE_CONF_PATH"

# 1) Start teldrive on localhost:8080 (match rclone remote api_host=http://localhost:8080)
TELDRIVE_ADDR="${TELDRIVE_ADDR:-127.0.0.1:8080}"
echo "Starting teldrive at $TELDRIVE_ADDR ..."
teldrive serve --config "$TELDRIVE_CONF_PATH" --addr "$TELDRIVE_ADDR" >/tmp/teldrive.log 2>&1 &

# 2) Wait a bit for teldrive to be ready (simple wait)
sleep 2

# 3) Run your exact rclone command
RCLONE_CMD="${RCLONE_CMD:-rclone copy --update --ignore-existing 'pgs:/TheGdriveXbot' 'teldrive:/TheGdriveXbot' -v}"
echo "Running: $RCLONE_CMD"
bash -lc "$RCLONE_CMD"

echo "Done."
