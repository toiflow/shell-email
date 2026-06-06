#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

EMAILS=$(osascript <<'OSEOF'
tell application "Mail"
    set allAccounts to every account
    set todayDate to current date
    set startOfDay to todayDate - (time of todayDate)
    set output to ""
    set selfAddresses to {}
    repeat with acct in allAccounts
        set end of selfAddresses to email addresses of acct
    end repeat
    repeat with acct in allAccounts
        set acctInboxes to every mailbox of acct whose name is "INBOX"
        repeat with mb in acctInboxes
            set flaggedMsgs to (messages of mb whose flagged status is true)
            repeat with m in flaggedMsgs
                set theSender to sender of m
                set isSelf to false
                repeat with addr in selfAddresses
                    if theSender contains addr then set isSelf to true
                end repeat
                if isSelf is false then
                    if (count of mail attachments of m) is 0 then
                        if (date received of m) >= startOfDay then
                            set output to output & "From: " & theSender & " | Subject: " & subject of m & "\n"
                        end if
                    end if
                end if
            end repeat
        end repeat
    end repeat
    return output
end tell
OSEOF
)

source /Users/jayagent/Documents/GitHub/shell-ollama/registers/must-update-md.sh

EMAIL_COUNT=$(echo "$EMAILS" | grep -c "From:" 2>/dev/null)
echo "$EMAILS" > /tmp/must-email-context.txt

OLLAMA_OK="false"
if /Users/jayagent/Documents/GitHub/shell-ollama/must-update-md.sh \
    "$PROMPT_EMAIL_DIGEST" /tmp/must-email-context.txt /tmp/must-email.md; then
  OLLAMA_OK="true"
fi
RESPONSE_CHARS=$(wc -c < /tmp/must-email.md | tr -d ' ')

cat > /tmp/must-email-send.scpt << 'SCPT'
tell application "Mail"
    set acctAddresses to {}
    repeat with acct in every account
        set end of acctAddresses to email addresses of acct
    end repeat
    set newMsg to make new outgoing message with properties {subject:"must-email", visible:false}
    tell newMsg
        repeat with addr in acctAddresses
            make new to recipient with properties {address:addr}
        end repeat
        make new cc recipient with properties {address:"jayreck996@gmail.com"}
        make new attachment with properties {file name:(POSIX file "/tmp/must-email.md") as alias}
    end tell
    send newMsg
end tell
SCPT
osascript /tmp/must-email-send.scpt > /tmp/must-email-send.out 2>&1 &
OSPID=$!
(sleep 30 && kill "$OSPID" 2>/dev/null) &
KILLPID=$!
wait "$OSPID"
kill "$KILLPID" 2>/dev/null; wait "$KILLPID" 2>/dev/null
MAIL_RESULT=$(cat /tmp/must-email-send.out 2>/dev/null)
MAIL_SENT="false"; [[ "$MAIL_RESULT" == "true" ]] && MAIL_SENT="true"

CSV_LOG="$HOME/.openclaw/logs/must-email.csv"
mkdir -p "$(dirname "$CSV_LOG")"
[[ ! -f "$CSV_LOG" ]] && echo "timestamp,script,emails_fetched,model,ollama_success,response_chars,mail_sent" > "$CSV_LOG"
echo "$(date -u +"%Y-%m-%dT%H:%M:%S"),must-email-personal,${EMAIL_COUNT},qwen2.5:7b,${OLLAMA_OK},${RESPONSE_CHARS},${MAIL_SENT}" >> "$CSV_LOG"
