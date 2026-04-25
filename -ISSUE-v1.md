<instructions>

ISSUE LOG
INSTRUCTION FOR AI MODEL:

ALWAYS ADD NEW ISSUE ENTRIES AT THE TOP, DIRECTLY BELOW THIS HEADER.

NEVER DELETE OR EDIT PREVIOUS ISSUE ENTRIES.

REQUIRED FORMAT FOR EACH ISSUE ENTRY:

## ISSUE:{NAME OF ENVIRONMENT} {YYYY-MM-DD HH:MM} → {CONTENT}

</instructions>

####### <!-- ANCHOR MARKER - ADD NEW ENTRIES BELOW -->

## ISSUE:AppleScript-email-address-property 2026-04-25 → `email address` is not a valid Mail.app AppleScript property. Caused syntax error -2740. Fixed by using `name of account` instead.

## ISSUE:tmp-permission-denied 2026-04-25 → /tmp/must-email.md was owned by a different Mac user from a prior run, causing write permission denied. Fixed by adding `rm -f /tmp/must-email.md` before writing.

## ISSUE:single-account-scope 2026-04-25 → Original script only read from `inbox` of account 1. Rewrote to loop through every account's INBOX mailbox so all configured Mail.app accounts are covered dynamically.