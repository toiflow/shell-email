#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

EMAILS=$(osascript <<'EOF'
tell application "Mail"
    set flaggedMsgs to (messages of inbox whose flagged status is true)
    set todayDate to current date
    set startOfDay to todayDate - (time of todayDate)
    set output to ""
    repeat with m in flaggedMsgs
        set theSender to sender of m
        if theSender does not contain "jayreck996@gmail.com" then
            if (count of mail attachments of m) is 0 then
                if (date received of m) >= startOfDay then
                    set output to output & "From: " & theSender & " | Subject: " & subject of m & "\n"
                end if
            end if
        end if
    end repeat
    return output
end tell
EOF
)

# save emails to temp file
echo "$EMAILS" > /tmp/must-emails-raw.txt

# clear session cache before running
setopt NULL_GLOB; rm -f ~/.openclaw/agents/main/sessions/must-update_email_content.jsonl*; unsetopt NULL_GLOB

ANALYSIS=$(/opt/homebrew/bin/openclaw agent --session-id must-update_email_content -m "analyze the flagged emails in /tmp/must-emails-raw.txt, only today mails, group them by topic/sender, highlight anything urgent or needing action." 2>&1 | grep -v "Gateway agent failed" | grep -v "falling back" | grep -v "gateway closed" | grep -v "loopback" | grep -v "compaction")

# save analysis to md file
echo "$ANALYSIS" > /tmp/must-email.md

# send email with md attachment via Mail app
osascript <<EOF
tell application "Mail"
    set newMsg to make new outgoing message with properties {subject:"must-inbox", visible:false}
    tell newMsg
        make new to recipient with properties {address:"jayreck996@gmail.com"}
        make new cc recipient with properties {address:"jayreck@gmail.com"}
        make new attachment with properties {file name:(POSIX file "/tmp/must-email.md") as alias}
    end tell
    send newMsg
end tell
EOF
