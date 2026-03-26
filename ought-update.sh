#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# run must-file first, then must-email sequentially
/Users/jayagent/Documents/Github/macmini/must-update_file_content.sh
/Users/jayagent/Documents/Github/macmini/must-update_email_content.sh
