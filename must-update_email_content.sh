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

PROMPT="Do not use any tools. Do not search the web. Do not edit files. Just read the following email list and indicate KPIs — group by topic/sender and highlight anything urgent or needing action:

$EMAILS"

# run ollama directly
ANALYSIS=$(curl -s http://127.0.0.1:11434/api/generate \
  -d "{\"model\":\"qwen2.5:7b\",\"prompt\":$(echo "$PROMPT" | /usr/bin/jq -Rs .),\"stream\":false}" \
  | /usr/bin/jq -r '.response')

# save analysis to md file
echo "$ANALYSIS" > /tmp/must-email.md

# send email with md attachment via Mail app
osascript <<EOF
tell application "Mail"
    set newMsg to make new outgoing message with properties {subject:"must-email", visible:false}
    tell newMsg
        make new to recipient with properties {address:"jayreck996@gmail.com"}
        make new cc recipient with properties {address:"jayreck@gmail.com"}
        make new attachment with properties {file name:(POSIX file "/tmp/must-email.md") as alias}
    end tell
    send newMsg
end tell
EOF
