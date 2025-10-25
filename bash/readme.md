# Script Beacon — Bash Module (`beam` CLI)

The official Bash client for **Script Beacon**, the telemetry layer for scripts. Capture every run automatically—logs, errors, and exit codes—with **a single line** at the top of your script.

---

## 🚀 Quick Start

### 1. Install

```bash
curl -fsSL https://raw.githubusercontent.com/Bleepit/scriptbeacon-clients/537ade9f9965af9de3432587449ea3bd477adf23/bash/install.sh | bash
```

This installs the `beam` command into `/usr/local/bin`.

---

### 2. Initialize your global ID (once)

```bash
beam init --id <YOUR_BEACON_ID>
beam verify
```

You can generate or copy your beacon ID from your Script Beacon dashboard. (`beam verify` performs a quick test run and prints a ✅ confirmation.)

---

### 3. Add one line to any script

At the very top of your Bash script:

```bash
#!/usr/bin/env beam
# Optional per-script overrides
export SB_ID="123e4567-89ab-4cde-0123-456789abcdef"
export SB_WRITE="optional-write-secret"
export SB_TAGS='app=backup,env=prod'

echo "Starting nightly backup..."
rsync -av /src /dst
```

That’s it.
Run your script as usual:

```bash
chmod +x nightly_backup.sh
./nightly_backup.sh
```

`beam` automatically:

* captures stdout and stderr
* appends an error epilogue on crash or non-zero exit
* gzips the log
* uploads it to Script Beacon (`/b/{id}/chunk-init → PUT → chunk-complete`)
* falls back gracefully if upload blocked or offline

At the end you’ll see:

```
beam: uploaded 14.2 KB (sha256 6fa2c1e3…) • exit=0 • run=sb_run_01HABCDEF
```

---

## 🧩 Alternate Usage

### Fail-open shim (when you can’t change the shebang)

Insert these lines at the top:

```bash
if [ -z "${SB_WRAP_ACTIVE:-}" ] && command -v beam >/dev/null 2>&1; then
  export SB_WRAP_ACTIVE=1
  exec beam -- "$0" "$@"
fi
```

Your script will run normally if `beam` isn’t installed, or be captured automatically if it is.

---

### Wrapper mode (CI / cron / ad-hoc)

```bash
SB_ID=<uuid> beam -- bash -lc 'echo "running report"; ./report.sh'
```

---

## ⚙️ Configuration

`beam` looks for credentials and settings in this order:

1. CLI flags
2. Script header exports (`SB_ID`, `SB_WRITE`, etc.)
3. Environment variables
4. Config file: `~/.config/scriptbeacon/config`
5. Defaults

### Environment variables

| Variable   | Description                                               | Required |
| ---------- | --------------------------------------------------------- | -------- |
| `SB_ID`    | Script Beacon ID for this script                          | ✅        |
| `SB_WRITE` | Optional write token (for authenticated writes)           | ⛔️       |
| `SB_API`   | API endpoint (defaults to `https://api.scriptbeacon.com`) | ⛔️       |
| `SB_TAGS`  | JSON or `k=v` pairs of tags to include                    | ⛔️       |

Example config file (`~/.config/scriptbeacon/config`):

```ini
SB_ID=46d191f0-8784-4df8-8ccd-2ef22e27d244
SB_API=https://api.scriptbeacon.com
SB_WRITE=abcdef1234567890
```

---

## 🧠 Commands

| Command                      | Description                                   |
| ---------------------------- | --------------------------------------------- |
| `beam init --id <UUID>`      | Create config file with default ID            |
| `beam login --write <TOKEN>` | Save your write token                         |
| `beam verify`                | Send a short test run and verify connectivity |
| `beam doctor`                | Check local dependencies                      |
| `beam status`                | Show current config as JSON                   |
| `beam version`               | Print CLI version                             |
| `beam help`                  | Show usage help                               |

---

## 📟 Output details

Each run uploads:

* stdout/stderr transcript (gzip)
* `started_at`, `ended_at`, `exit_code`
* `bytes`, `sha256_hex`
* `tags` (merged with enrichers: `host`, `user`, `shell`)

If Script Beacon blocks or throttles the request:

* The run continues normally.
* A warning is printed.
* The local log path is preserved (`/tmp/beam-*.clean.log`).

---

## 🛠️ Requirements

* bash ≥ 4.0
* curl, gzip
* jq *or* python3 (for lightweight JSON parsing)

`beam doctor` will check all dependencies for you.

---

## 🧪 Examples

### Basic

```bash
#!/usr/bin/env beam
echo "Hello from Script Beacon"
sleep 1
exit 0
```

### With tags and secret

```bash
#!/usr/bin/env beam
export SB_ID="f2d1a60d-bad1-42e5-b8b7-a19c4b4ed123"
export SB_WRITE="my-secret"
export SB_TAGS='client=acme,region=us-east'
./deploy.sh
```

### Fail-open shim

```bash
if [ -z "${SB_WRAP_ACTIVE:-}" ] && command -v beam >/dev/null 2>&1; then
  export SB_WRAP_ACTIVE=1
  exec beam -- "$0" "$@"
fi

echo "Script runs even if Script Beacon not installed"
```

---

## 🔒 Security & Privacy

* All logs are gzipped before upload.
* Secrets are never echoed or logged.
* Config file permissions are enforced at 0600.
* If `SB_WRITE` is missing or invalid, the script still runs but upload is skipped.

---

## 🖯 Troubleshooting

* **`beam: SB_ID is required`** — Set `SB_ID` in your script or run `beam init --id <uuid>`.
* **`curl: command not found`** — Install `curl` (required for upload).
* **Upload blocked / offline** — You’ll see:
  `beam: upload blocked (HTTP 403) • local log kept at /tmp/...`

Run `beam doctor` to verify all dependencies.

---

## 🧩 Advanced

### Local testing without network

Run with `SB_API="file://"` to disable uploads and just generate logs.

### Custom API endpoints

```bash
export SB_API="https://api.dev.scriptbeacon.com"
```

---

## 🧺 License

MIT License © Script Beacon
See [LICENSE](../LICENSE) for details.

---

**Instant visibility. Zero boilerplate.**
Just add:

```bash
#!/usr/bin/env beam
```

and start seeing
