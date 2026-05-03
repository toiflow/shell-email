<instructions>

ISSUE LOG
INSTRUCTION FOR AI MODEL:

ALWAYS ADD NEW ISSUE ENTRIES AT THE TOP, DIRECTLY BELOW THIS HEADER.

NEVER DELETE OR EDIT PREVIOUS ISSUE ENTRIES.

REQUIRED FORMAT FOR EACH ISSUE ENTRY:

## ISSUE:{NAME OF ENVIRONMENT} {YYYY-MM-DD HH:MM} → {CONTENT}

</instructions>

####### <!-- ANCHOR MARKER - ADD NEW ENTRIES BELOW -->

## ISSUE:cron-automation-permission 2026-05-03 → cron not authorized to send Apple events to Mail.app (-1743). Script runs fine from terminal but fails silently when fired by cron. Fixed by enabling Mail permission for cron in System Settings → Privacy & Security → Automation. Confirmed sending successfully at 15:15.

## ISSUE:email-addresses-type-coercion 2026-04-30 → `email addresses of acct` on Google Workspace accounts returns a non-iterable type, causing -1700 coercion errors in both the selfAddresses filter and recipient build loops. Gmail accounts handle it differently and don't exhibit this. Fixed in must-email-work.sh by replacing both loops with `name of every account` which returns a clean flat list of email addresses for this account type.

## ISSUE:launchd-exit-127 2026-04-30 → com.user.must-email-work.plist failed with exit code 127 (command not found) when firing automatically via launchd. Root cause not confirmed. Resolved by removing launchd schedule and switching to crontab (0 18 * * *) consistent with personal script approach.

## ISSUE:work-script-pulling-wrong-account 2026-04-30 → must-email-work.sh generating analysis from jayagent account content instead of admin@toigroup.co.nz. Root cause unconfirmed — possible launchd context issue or subtle script drift. Fixed by clean rewrite of must-email-work.sh using must-email-personal.sh as reference base. Email subject updated to "must-email-work" to distinguish from personal script in inbox.

## ISSUE:tmp-cross-user-conflict 2026-04-27 → /tmp/must-email.md owned by jayagent (personal Mac user). reckagent (work Mac user) cannot rm -f or write to it. rm -f fix from 2026-04-25 was incomplete — only worked for the owning user. Fixed in must-email-work.sh by using /tmp/must-email-work.md as a unique per-script temp filename.

## ISSUE:account-name-not-email-address 2026-04-27 → `name of every account` in Mail.app AppleScript returns display name (e.g. "Google"), not actual email address. Caused emails to be sent to invalid recipients. Fixed by looping `email addresses of acct` to build address list. Applied to both selfAddresses filter and recipient list in must-email-personal.sh and must-email-work.sh.

## ISSUE:AppleScript-email-address-property 2026-04-25 → `email address` is not a valid Mail.app AppleScript property. Caused syntax error -2740. Fixed by using `name of account` instead.

## ISSUE:tmp-permission-denied 2026-04-25 → /tmp/must-email.md was owned by a different Mac user from a prior run, causing write permission denied. Fixed by adding `rm -f /tmp/must-email.md` before writing.

## ISSUE:single-account-scope 2026-04-25 → Original script only read from `inbox` of account 1. Rewrote to loop through every account's INBOX mailbox so all configured Mail.app accounts are covered dynamically.