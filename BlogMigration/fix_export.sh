#!/bin/bash
#
# Fix problems with MovableType backup files
#
# This should be run from within the wp-uploads/domainname/import folder, prior to import.
# Ensure you remove any clean-*.xml files that the WordPress Backup Importer plugin has created.

# Some comments have junk_status incorrectly set to 0, so WordPress will ignore them. Change to 1.
for i in `ls M*.xml` ; do
	echo $i
	sed s/junk\_status\=\'0\'/junk\_status\=\'1\'/ <$i > $i.1
	mv $i.1 $i
done

# Sometimes the post data has incorrect entity encoding; if this happens, fix it. Hard-coded for each case and each file
sed 's/7\&#4/7\&#35;4/' < Movable_Type-2011-10-21-07-57-48-Backup-9.xml > Movable_Type-2011-10-21-07-57-48-Backup-9.xml.1
mv Movable_Type-2011-10-21-07-57-48-Backup-9.xml.1 Movable_Type-2011-10-21-07-57-48-Backup-9.xml
