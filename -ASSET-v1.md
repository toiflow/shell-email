<instructions>

ASSET LOG
INSTRUCTION FOR AI MODEL:

ALWAYS ADD NEW ASSET ENTRIES AT THE TOP, DIRECTLY BELOW THIS HEADER.

NEVER DELETE OR EDIT PREVIOUS ASSET ENTRIES.

REQUIRED FORMAT FOR EACH ASSET ENTRY:

## ASSET:{NAME OF ENVIRONMENT} {YYYY-MM-DD HH:MM} → {CONTENT}

</instructions>

####### <!-- ANCHOR MARKER - ADD NEW ENTRIES BELOW -->

## ASSET:com.user.must-email-work.plist 2026-04-25 → launchd schedule for must-email-work.sh. Runs daily at 18:00. Loaded into ~/Library/LaunchAgents/. Logs to /tmp/must-email-work.log and /tmp/must-email-work-err.log.

## ASSET:must-email-personal.sh 2026-04-25 → Flagged emails only + today filter. Dynamically reads all Mail.app accounts. Sends analysis to all accounts, CC jayreck996@gmail.com. Runs on jayreck996 Mac user account.

## ASSET:must-email-work.sh 2026-04-25 → All emails (non-flagged included) + today filter. Dynamically reads all Mail.app accounts. Sends analysis to all accounts, no CC. Runs on work Mac user accounts (admin@toigroup.co.nz / admin@toifood.co.nz).
