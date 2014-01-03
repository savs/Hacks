#!/bin/bash
#
# This script closes Mail, removes the mail indexes, and reopens Mail.
# This should (in theory) force Mail to reindex all mail.
echo "- Killing Mail..."
/usr/bin/env osascript <<-EOF
tell application "Mail"
	quit
end tell
repeat
    tell application "System Events"
	    if "Mail" is not in (name of application processes) then exit repeat
    end tell
    delay 5
end repeat
EOF
echo "- Mail quit, backing-up..."
DATE=`date +'%Y%m%d%H%M'`
mkdir ~/Mail-$DATE
mv ~/Library/Mail/V2/MailData/Envelope* ~/Mail-$DATE/
echo "- Starting Mail..."
/usr/bin/env osascript <<-EOF
tell application "Mail"
	activate
end tell
EOF
