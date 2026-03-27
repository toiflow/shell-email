#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# clear session cache before running
setopt NULL_GLOB; rm -f ~/.openclaw/agents/main/sessions/must-update-file.jsonl*; unsetopt NULL_GLOB

# analyze Google Sheet
ANALYSIS=$(/opt/homebrew/bin/openclaw agent --session-id must-update-file -m "read the Google Spreadsheet at https://docs.google.com/spreadsheets/d/1VsRoh9Wg3TSAGJNtJHnovIqxzqKT-1ti1xbM7_DPEG0 using win=completed, tie=in progress, lost=incomplete. Indicate KPIs — summarize what tasks are completed, in progress, and incomplete. Highlight anything urgent or needing attention." 2>&1 | grep -v "Gateway agent failed" | grep -v "falling back" | grep -v "gateway closed" | grep -v "loopback" | grep -v "compaction")

# save analysis to md file
echo "$ANALYSIS" > /tmp/must-file.md

# send email with md attachment via Mail app
osascript <<EOF
tell application "Mail"
    set newMsg to make new outgoing message with properties {subject:"must-file", visible:false}
    tell newMsg
        make new to recipient with properties {address:"jayreck996@gmail.com"}
        make new cc recipient with properties {address:"jayreck@gmail.com"}
        make new attachment with properties {file name:(POSIX file "/tmp/must-file.md") as alias}
    end tell
    send newMsg
end tell
EOF
