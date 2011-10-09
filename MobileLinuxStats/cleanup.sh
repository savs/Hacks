#!/bin/bash
# Get rid of output of stats.pl in each project directory

for i in Tizen MeeGo Maemo ; do
	echo "Cleaning $i"
	rm $i/*.gif
	rm $i/*.html
done
