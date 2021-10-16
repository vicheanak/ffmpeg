#!/bin/bash

#Delete output.mp4
output="output.mp4"
if [ -f "$file" ] ; then
    rm "$file"
fi

#Create tmp_source
[[ -d ./test ]] && rm -r ./test
mkdir tmp_source

#Convert to same codec
FILES="./source/*"
for f in $FILES; 
do ffmpeg -i $f -s hd720 -r 30000/1001 -video_track_timescale 30k -c:a copy ./tmp_source/${f/"./source/"/""}; 
done

#Read Files
ls ./tmp_source | xargs -i echo "file './tmp_source/{}'" > list.txt

#Merge
ffmpeg -y -f concat -safe 0 -i list.txt -c copy merge.mp4


#Change Speed
ffmpeg -y -i merge.mp4 -r 30 -filter_complex "[0:v]setpts=0.8*PTS[v];[0:a]atempo=1.2[a]" -map "[v]" -map "[a]" speed.mp4

#Flip
ffmpeg -y -i speed.mp4 -vf hflip flip.mp4

# #Black background
ffmpeg -y -i flip.mp4 -filter_complex "pad=1280:0:(ow-iw)/2" output.mp4

#Delete junk files
rm -rf tmp_source
rm ./source/*
rm merge.mp4
rm speed.mp4
rm flip.mp4
rm list.txt
