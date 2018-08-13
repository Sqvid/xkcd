#!/bin/bash

if [ $# -gt 1 ]; then
	echo "Too many input arguments."
	exit 1
elif [[ $# -eq 1 && "$1" != "-q" ]]; then
	echo "Unrecognised input argument."
	exit 2
fi

if [ -f xkcd.html ]; then
	rm xkcd.html
fi

if [ ! -f .xkcd_history ]; then
	touch .xkcd_history
fi

histLength=$(wc -l .xkcd_history | cut -d " " -f 1)

if [ $histLength -gt 10 ]; then
	lastEntry=$(tail -n 1 .xkcd_history) 
	echo $lastEntry > .xkcd_history
fi

if [ $# -eq 0 ]; then
	echo "Refreshing HTML file..."
fi

wget --quiet https://xkcd.com/ -O xkcd.html

comicNum=$(grep 'Permanent link to this comic:' < xkcd.html | cut -d "/" -f 4)
comicLink=$(grep 'Image URL (for hotlinking/embedding):' < xkcd.html | cut -d ":" -f 2,3)
imageFormat=$(echo $comicLink | cut -d "." -f 4)

if [ ! -d ~/Pictures/xkcd/ ]; then
	mkdir -p ~/Pictures/xkcd/
fi

if [[ $histLength -gt 0 &&  $comicNum -eq $(tail -n 1 .xkcd_history) &&\
	-f ~/Pictures/xkcd/${comicNum}.${imageFormat} ]]; then

	if [ $# -eq 0 ]; then
		echo "Comic number $comicNum is already available."
		echo "Opening comic..."
		display ~/Pictures/xkcd/${comicNum}.${imageFormat} &
	fi
else
	if [ $# -eq 0 ]; then 
		echo "Fetching comic..."
		wget --quiet $comicLink -O ~/Pictures/xkcd/${comicNum}.${imageFormat}
		echo $comicNum >> .xkcd_history
		echo "Opening comic..."
		display ~/Pictures/xkcd/${comicNum}.${imageFormat} &
	else
		wget --quiet $comicLink -O ~/Pictures/xkcd/${comicNum}.${imageFormat}
		echo $comicNum >> .xkcd_history
	fi
fi

exit 0
