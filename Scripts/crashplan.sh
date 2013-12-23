#!/bin/bash
# http://hints.macworld.com/article.php?story=20110124224322791
# http://support.code42.com/CrashPlan/Latest/Troubleshooting/Stopping_and_Starting_The_CrashPlan_App
NO_ARGS=0

usage ()
{
cat <<EOF
usage: crashplan.sh [action]

   action: on | off

Disables or enables crashplan backup service.
If run without <action>, toggles the service.

EOF
}

if [ $# -eq "$NO_ARGS" ] # No command-line arguments?
then
        usage
        exit 0
	# FIXME toggle if no arguments
fi

case "$1" in
	"on")
		echo "Turning on crashplan. Please enter root password if prompted."
		sudo launchctl load /Library/LaunchDaemons/com.crashplan.engine.plist
		sudo launchctl start com.crashplan.engine
		;;
	"off")
		echo "Turning off crashplan. Please enter root password if prompted."
		sudo launchctl stop com.crashplan.engine
		sudo launchctl unload /Library/LaunchDaemons/com.crashplan.engine.plist
		;;
	*)
		echo "Unrecognised option: $0"
		;;
esac


