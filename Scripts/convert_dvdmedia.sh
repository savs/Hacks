#!/bin/bash
# Install transcode-video from https://github.com/donmelton/video_transcoding
MOVIEPATH="/Volumes/Media/Movies"
OUTPUTPATH="/Volumes/Media/Transcoded Movies"

find -s $MOVIEPATH -maxdepth 1 -type d -name '*.dvdmedia' | while read file; do

        # file: /Volumes/Movies/2001 A Space Odyssey.dvdmedia
        # filename: 2001 A Space Odyssey.dvdmedia
        # basename: 2001 A Space Odyssey

        filename=`basename "$file"`
        basename=${filename%.*}
        echo -n "$basename: "

        if [ ! -d "$file/VIDEO_TS" ] ; then
                echo "$basename does not look like a dvdmedia folder"
        fi

	transcode-video -q -o "${OUTPUTPATH}"/"${basename}".mkv "${MOVIEPATH}"/"${filename}"

done
exit 0
