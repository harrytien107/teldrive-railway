# Teldrive-rclone

Automated file synchronization between Google Drive and [Teldrive](https://teldrive-docs.pages.dev/) using the [tgdrive rclone fork](https://github.com/tgdrive/rclone), deployed on [Railway](https://railway.com/).

# Deploy and Host

Deploy a Docker-based service on Railway that installs the **latest** Teldrive and tgdrive rclone fork at build time. At runtime, configuration files are injected securely via base64-encoded environment variables. The service starts Teldrive locally, executes rclone copy/sync commands, and exits cleanly — ideal for Railway Cron scheduling.

## Common Use Cases

- 📂 Automatically mirror Google Drive folders into Teldrive storage
- 🔁 Run scheduled backups or incremental file synchronization
- ☁️ Host a lightweight private file gateway powered by Teldrive
- 🧪 Test and automate tgdrive workflows in a cloud environment

## Dependencies for Hosting

- **Docker** — container runtime for building and running the service
- **Teldrive** — backend service for Telegram-based file storage
- **tgdrive rclone fork** — rclone fork with Teldrive remote support
- **PostgreSQL** — database backend (e.g. Supabase)

### Deployment Dependencies

- [Teldrive Releases](https://github.com/tgdrive/teldrive/releases)
- [tgdrive rclone Fork](https://github.com/tgdrive/rclone/releases)
- [Teldrive Documentation](https://teldrive-docs.pages.dev/)
- [Railway Platform](https://railway.com/)

## Why Deploy on Railway

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.

---

## 🚀 Quick Start

### 1. Deploy from GitHub

1. Go to [railway.com](https://railway.com/) → **New Project** → **Deploy from GitHub**
2. Select this repository
3. Wait for Railway to clone and create the service

### 2. Set Environment Variables

Go to **Service → Variables** and add:

| Variable | Required | Description |
|---|---|---|
| `DATA_DIR` | ✅ | Directory for configs (`/tmp` if no volume, `/data` with volume) |
| `TELDRIVE_CONFIG_B64` | ✅ | Base64 of your `config.toml` |
| `TELDRIVE_CONFIG_PATH` | ✅ | Path to config file (e.g. `/tmp/config.toml`) |
| `RCLONE_CONF_B64` | ✅ | Base64 of your `rclone.conf` |
| `RCLONE_CONFIG_PATH` | ✅ | Path to rclone config (e.g. `/tmp/rclone.conf`) |
| `RCLONE_CMD` | ✅ | Full rclone command to run (see below) |

### 3. (Optional) Add Volume

If your plan supports it: **Architecture canvas → ➕ → Volume** → attach to service → mount at `/data`.

> Without a volume, configs are re-decoded from base64 on every run. This works fine for cron jobs.

### 4. Redeploy

Click **Redeploy** and check **Logs**.

---

## 📝 Configuration

### Generate Base64 Configs

**PowerShell (Windows):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("config.toml"))
[Convert]::ToBase64String([IO.File]::ReadAllBytes("rclone.conf"))
```

**Linux / macOS:**
```bash
base64 -w0 config.toml
base64 -w0 rclone.conf
```

### Recommended `RCLONE_CMD`

Optimized for Railway (low memory, rate-limit safe):

```
rclone copy --update --ignore-existing 'pgs:/TheGdriveXbot' 'teldrive:/TheGdriveXbot' -v --transfers 2 --checkers 2 --buffer-size 8M --drive-chunk-size 8M --tpslimit 2 --low-level-retries 3 --retries 3 --retries-sleep 10s
```

**If you hit Google API rate limits**, reduce further:
```
--tpslimit 1 --transfers 1 --checkers 1 --drive-skip-shortcuts
```

**To set a max runtime** (e.g. 2 hours):
```
timeout 2h rclone copy ...
```

---

## ⏱️ Cron Schedule

For periodic sync, enable **Cron** in Service → Settings:

| Schedule | Expression |
|---|---|
| Every 6 hours | `0 */6 * * *` |
| Every 2 days at midnight | `0 0 */2 * *` |
| Daily at 2:00 AM | `0 2 * * *` |

> The job runs → finishes → exits. Cron only controls *when* it starts, not how long it runs.

---

## 🔄 Auto-Update

The Dockerfile automatically fetches the **latest releases** of both Teldrive and rclone (tgdrive fork) at build time via the GitHub Releases API. Every redeploy pulls the newest versions.

---

## ❗ Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Missing config.toml` | `TELDRIVE_CONFIG_B64` not set or bad base64 | Re-encode as single-line base64, paste into Variables |
| `connection refused 127.0.0.1:8080` | Teldrive not started yet | Increase wait time in `entrypoint.sh` |
| `unknown command "serve"` | Wrong teldrive command | Use `teldrive run` (already fixed in entrypoint) |
| `RATE_LIMIT_EXCEEDED` | Google Drive API quota hit | Add `--tpslimit 1 --drive-skip-shortcuts` |
| `Out of memory` | Too much concurrency | Reduce `--transfers`, `--checkers`, `--buffer-size` |
| `CHANNEL_INVALID` | Telegram channel not configured | Check `config.toml` channel settings |
| `EOF` | Teldrive crashed mid-request | Check teldrive logs for DB/auth errors |

---

## 📚 References

- [Teldrive Docs](https://teldrive-docs.pages.dev/)
- [Teldrive CLI — `run` command](https://teldrive-docs.pages.dev/docs/cli/run)
- [Railway Variables](https://docs.railway.com/guides/variables)
- [Railway Volumes](https://docs.railway.com/reference/volumes)
- [Railway Cron Jobs](https://docs.railway.com/reference/cron-jobs)
- [Railway Dockerfiles](https://docs.railway.com/guides/dockerfiles)
- [rclone Google Drive Backend](https://rclone.org/drive/)
