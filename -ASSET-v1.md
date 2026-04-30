<instructions>

ASSET LOG
INSTRUCTION FOR AI MODEL:

ALWAYS ADD NEW ASSET ENTRIES AT THE TOP, DIRECTLY BELOW THIS HEADER.

NEVER DELETE OR EDIT PREVIOUS ASSET ENTRIES.

REQUIRED FORMAT FOR EACH ASSET ENTRY:

## ASSET:{NAME OF ENVIRONMENT} {YYYY-MM-DD HH:MM} → {CONTENT}

</instructions>

####### <!-- ANCHOR MARKER - ADD NEW ENTRIES BELOW -->

## ASSET:must-email-work.sh 2026-04-30 16:00 → Fixed email-addresses coercion error. Replaced `email addresses of acct` loops with `name of every account` in both selfAddresses filter and recipient build. Confirmed sending successfully.

## ASSET:crontab-must-email-work 2026-04-30 → cron entry added at `0 18 * * *` for must-email-work.sh on reckagent account. Replaced launchd plist (com.user.must-email-work.plist) which failed with exit 127. Logs to /tmp/must-email-work.log.

## ASSET:must-email-work.sh 2026-04-30 → Clean rewrite using must-email-personal.sh as reference. All emails + today filter, temp file /tmp/must-email-work.md, email subject "must-email-work", no CC. Resolves wrong-account content issue.

## ASSET:must-email-work.sh 2026-04-27 → Updated temp file from /tmp/must-email.md to /tmp/must-email-work.md to avoid cross-user permission conflict with personal script. Confirmed working — sends analysis email successfully.

## ASSET:crontab-must-email-personal 2026-04-25 18:10 → cron entry added at `5 18 * * *` for must-email-personal.sh on jayreck996 account. Offset 5 min from ought-update.sh (18:00) to avoid clash. Logs to /Users/jayagent/.openclaw/logs/must-email-personal.log.

## ASSET:com.user.must-email-work.plist 2026-04-25 → launchd schedule for must-email-work.sh. Runs daily at 18:00. Loaded into ~/Library/LaunchAgents/. Logs to /tmp/must-email-work.log and /tmp/must-email-work-err.log.

## ASSET:must-email-personal.sh 2026-04-25 → Flagged emails only + today filter. Dynamically reads all Mail.app accounts. Sends analysis to all accounts, CC jayreck996@gmail.com. Runs on jayreck996 Mac user account.

## ASSET:must-email-work.sh 2026-04-25 → All emails (non-flagged included) + today filter. Dynamically reads all Mail.app accounts. Sends analysis to all accounts, no CC. Runs on work Mac user accounts (admin@toigroup.co.nz / admin@toifood.co.nz).
