# Teldrive + tgdrive rclone on Railway

## Railway settings
- Create service from this repo (Deploy from GitHub)
- Create a Volume mounted at: `/data`
- Add Variables (Secrets):
  - TELDRIVE_CONF_B64
  - RCLONE_CONF_B64
  - RUN_MODE = serve or sync

## Base64 helper
Linux/macOS:
  base64 -w0 teldrive.conf
  base64 -w0 rclone.conf

PowerShell:
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("teldrive.conf"))
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("rclone.conf"))

## Cron (recommended for sync)
Set:
- RUN_MODE=sync
- SYNC_SRC=...
- SYNC_DST=...
- RCLONE_FLAGS=-v

Then enable Railway Cron Schedule on the service.
