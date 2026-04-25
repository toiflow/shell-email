#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

EMAILS=$(osascript <<'OSEOF'
tell application "Mail"
    set allAccounts to every account
    set todayDate to current date
    set startOfDay to todayDate - (time of todayDate)
    set output to ""
    set selfAddresses to name of every account
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

PROMPT="Do not use any tools. Do not search the web. Do not edit files. Just read the following email list and indicate — group by topic/sender and highlight anything urgent or needing action:

$EMAILS"

ANALYSIS=$(curl -s http://127.0.0.1:11434/api/generate \
  -d "{\"model\":\"qwen2.5:7b\",\"prompt\":$(echo "$PROMPT" | /usr/bin/jq -Rs .),\"stream\":false}" \
  | /usr/bin/jq -r '.response')

rm -f /tmp/must-email.md
echo "$ANALYSIS" > /tmp/must-email.md

osascript <<OSEOF
tell application "Mail"
    set acctAddresses to name of every account
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
OSEOF
