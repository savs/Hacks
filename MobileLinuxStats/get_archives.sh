#!/bin/bash
# Simple script to download named lists from a range of projects.

echo "Project MeeGo"
if [ ! -d "MeeGo" ] ; then
	mkdir MeeGo
fi
cd MeeGo
for i in meego-adaptation-intel-automotive meego-announce meego-architecture meego-commits meego-community meego-dev meego-distribution-tools meego-events meego-handset meego-il10n meego-inputmethods meego-it meego-ivi meego-kernel meego-packaging meego-pm meego-porting meego-python meego-qa meego-releases meego-sdk meego-security meego-security-discussion meego-touch-dev meego-tv ; do
	echo "Getting $i"
	if [ ! -d $i ] ; then
		mkdir $i
	fi
	cd $i
	wget -nv -nd -N -r -l 1 -A .gz http://lists.meego.com/pipermail/$i/
	cd ..
done
cd ..

echo "Project Tizen"
if [ ! -d "Tizen" ] ; then
	mkdir Tizen
fi
cd Tizen
for i in general ; do
	echo "Getting $i"
	if [ ! -d $i ] ; then
		mkdir $i
	fi
	cd $i
	wget -nv -nd -N -r -l 1 -A .gz http://lists.tizen.org/pipermail/$i/
	cd ..
done
cd ..

echo "Project Maemo"
if [ ! -d "Maemo" ] ; then
        mkdir Maemo
fi
cd Maemo
for i in maemo-announce maemo-commits maemo-community maemo-developers maemo-users ; do
        echo "Getting $i"
        if [ ! -d $i ] ; then
                mkdir $i
        fi
        cd $i
        wget -nv -nd -N -r -l 1 -A .gz http://lists.maemo.org/pipermail/$i/
        cd ..
done
cd ..
