#!/bin/bash

##
## SCRIPT TO DEVIDE MEDIA FILES INTO FOLDERS BY DATE
##
## Example: IMG_20200130_000027.jpg

## Create list of folders by date
DIR_LIST=$(ls $HOME/sep4.20-uncategorized|sed 's/[^0-9]*//g' |cut -c -8|sort -u |sed '/^[[:space:]]*$/d'|tr '\n' ' ')

echo ... creating folders:
echo $DIR_LIST| tr ' ' '\n'

mkdir $(echo $DIR_LIST)

echo ... moving files
for i in *.jpg *.mp4; do
	## Move media files  taken in the same day to the same folder
	DIR_BELONGS=$(echo $i| sed 's/[^0-9]*//g' |cut -c -8|sort -u |sed '/^[[:space:]]*$/d')
	mv $i $DIR_BELONGS
done

echo ... done
