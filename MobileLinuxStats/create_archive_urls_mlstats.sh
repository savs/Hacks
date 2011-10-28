#!/bin/bash
# Simple script to create URLs for MLStats
# Run as:
# ./create_archive_urls_mlstats.sh > lists.txt
# Or:
# ./create_archive_urls_mlstats.sh | mlstats -


# MEEGO
for i in meego-adaptation-intel-automotive meego-announce meego-architecture meego-commits meego-community meego-dev meego-distribution-tools meego-events meego-handset meego-il10n meego-inputmethods meego-it meego-ivi meego-kernel meego-packaging meego-pm meego-porting meego-python meego-qa meego-releases meego-sdk meego-security meego-security-discussion meego-touch-dev meego-tv ; do
	echo "http://lists.meego.com/pipermail/$i/"
done

# TIZEN
for i in general ; do
	echo "http://lists.tizen.org/pipermail/$i/"
done

# Maemo
for i in maemo-announce maemo-commits maemo-community maemo-developers maemo-users ; do
    echo "http://lists.maemo.org/pipermail/$i/"
done

# Ubuntu
for i in ubuntu-devel ubuntu-devel-discuss ; do
    echo "http://lists.ubuntu.com/archives/$i/"
done
