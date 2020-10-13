#!/bin/sh
## Script to get audio from Youtube video and convert to mp3 extension
## requiremwnt: youtube-dl, ffmpeg 


[ -z $1 ] && {
	echo Usage: ./yt-mp3 [URL] [outfile] ;
	echo Example: ./yt-mp3 https://www.youtube.com/watch?v=cQETxhwDopE ngoi_nha_hanh_phuc;
	echo "(use quotation marks/underlines for outfile)";
	exit 1;
	}

URL=$1
OUT_FILE=$2

audio_line=$( youtube-dl -F $URL |grep "audio only"|tail -n 1 )

##
title_raw=$(  wget --quiet -O - $URL  | sed -n -e 's!.*<title>\(.*\)</title>.*!\1!p' )
echo .original title: $title_raw

##
best_quality=$( echo $audio_line |awk '{print $1; exit}' )
echo .best audio quality: $best_quality

##
audio_ext=$( echo $audio_line| awk  '{print $2}' )
echo .audio extension: $audio_ext



youtube-dl -f $best_quality $URL --output "$OUT_FILE.$audio_ext"

[[ ! "$audio_ext" == "mp3" ]] && {
	echo .downloaded file is "$OUTFILE.$audio_ext", converting to mp3;
	ffmpeg -hide_banner -loglevel panic -i "$OUT_FILE.$audio_ext"  "$OUT_FILE.mp3";
	}
echo .removing temporal file: "$OUT_FILE.$audio_ext"
rm "$OUT_FILE.$audio_ext"
echo .done!
