<instructions>

ASSET LOG
INSTRUCTION FOR AI MODEL:

ALWAYS ADD NEW ASSET ENTRIES AT THE TOP, DIRECTLY BELOW THIS HEADER.

NEVER DELETE OR EDIT PREVIOUS ASSET ENTRIES.

REQUIRED FORMAT FOR EACH ASSET ENTRY:

## ASSET:{NAME OF ENVIRONMENT} {YYYY-MM-DD HH:MM} → {CONTENT}

</instructions>

####### <!-- ANCHOR MARKER - ADD NEW ENTRIES BELOW -->

## ASSET:shell-email 2026-06-05 → migrated to toiflow org + GitHub Actions pipeline

| Change | Detail |
|---|---|
| Repo | `jayreck996/shell-email` → `toiflow/shell-email` |
| Local remote | Updated to `https://github.com/toiflow/shell-email.git` |
| Scheduler | Local cron (Mac-bound) → `.github/workflows/would-update.yml` (cron `0 18 * * *`) |
| Email fetch | AppleScript/Mail.app → `would-read-md.js` (Gmail API, OAuth2 via fetch, no npm) |
| Ollama | Direct call → reusable `toiflow/-toiflow/.github/workflows/must-update-access.yml` |
| GitHub write | `would-update-content.js` — `github.token` with `contents: write` |
| Output | `would/-content-issue-v1.md`, `would/-content-asset-v1.md` |
| Org secrets | `OLLAMA_SECRET`, `OLLAMA_URL` inherited from toiflow org automatically |
| Pending | Gmail OAuth secrets (`GMAIL_CLIENT_ID`, `GMAIL_CLIENT_SECRET`, `GMAIL_REFRESH_TOKEN`) — repo-level or org-level once token obtained |

## ASSET:must-email-work.sh 2026-05-06 → Fully operational via cron on reckagent.
- Cron: `0 18 * * *`
- Reads all non-flagged, non-self, no-attachment emails from INBOX since midnight
- Uses `name of every account` for selfAddresses filter and recipient list (Google Workspace fix — `email addresses of acct` returns list type)
- Sends `.md` attachment via Mail.app to admin@toigroup.co.nz
- SMTP: smtp.gmail.com:587, TLS, App Password auth
- Confirmed: 16 emails fetched, inbox delivery 2026-05-06T02:10:43

## ASSET:must-email-work.sh 2026-05-04 → Added `mkdir -p` before CSV log write in both must-email-work.sh and must-email-personal.sh. Resolves exit 1 on reckagent where ~/.openclaw/logs/ did not exist. Confirmed exit 0 and CSV logging operational.

## ASSET:cron-automation-permission 2026-05-03 → Mail permission granted to cron via System Settings → Privacy & Security → Automation on reckagent account. Required for crontab to control Mail.app. Confirmed working.

## ASSET:must-email-work.sh 2026-04-30 16:00 → Fixed email-addresses coercion error. Replaced `email addresses of acct` loops with `name of every account` in both selfAddresses filter and recipient build. Confirmed sending successfully.

## ASSET:crontab-must-email-work 2026-04-30 → cron entry added at `0 18 * * *` for must-email-work.sh on reckagent account. Replaced launchd plist (com.user.must-email-work.plist) which failed with exit 127. Logs to /tmp/must-email-work.log.

## ASSET:must-email-work.sh 2026-04-30 → Clean rewrite using must-email-personal.sh as reference. All emails + today filter, temp file /tmp/must-email-work.md, email subject "must-email-work", no CC. Resolves wrong-account content issue.

## ASSET:must-email-work.sh 2026-04-27 → Updated temp file from /tmp/must-email.md to /tmp/must-email-work.md to avoid cross-user permission conflict with personal script. Confirmed working — sends analysis email successfully.

## ASSET:crontab-must-email-personal 2026-04-25 18:10 → cron entry added at `5 18 * * *` for must-email-personal.sh on jayreck996 account. Offset 5 min from ought-update.sh (18:00) to avoid clash. Logs to /Users/jayagent/.openclaw/logs/must-email-personal.log.

## ASSET:com.user.must-email-work.plist 2026-04-25 → launchd schedule for must-email-work.sh. Runs daily at 18:00. Loaded into ~/Library/LaunchAgents/. Logs to /tmp/must-email-work.log and /tmp/must-email-work-err.log.

## ASSET:must-email-personal.sh 2026-04-25 → Flagged emails only + today filter. Dynamically reads all Mail.app accounts. Sends analysis to all accounts, CC jayreck996@gmail.com. Runs on jayreck996 Mac user account.

## ASSET:must-email-work.sh 2026-04-25 → All emails (non-flagged included) + today filter. Dynamically reads all Mail.app accounts. Sends analysis to all accounts, no CC. Runs on work Mac user accounts (admin@toigroup.co.nz / admin@toifood.co.nz).
