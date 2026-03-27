#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# clear old session files
rm -f ~/.openclaw/agents/main/sessions/*.jsonl* 2>/dev/null

# rotate logs
> ~/.openclaw/logs/ought-update.log
> ~/.openclaw/logs/must-update_email_content.log
> ~/.openclaw/logs/must-update_file_content.log

# restart ollama model
ollama stop qwen2.5-claw:7b 2>/dev/null
sleep 3
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model":"qwen2.5-claw:7b","prompt":"hi","stream":false}' > /dev/null

echo "maintenance done"
