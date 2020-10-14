##
## Procedure: scan documents with phone camera and convert to pdf
##
## last update: Thursday, October 15, 2020

## PACKAGES:
## "imagemagick" package is required by "convert" command
## "img2pdf" package is required by "img2pdf" command
## "ffmpeg" package is required by "ffmpeg" command
## "pdftk" packages is required by "pdftk" command

## 0/ Take images of the document

## 1/ Compress the taken images as .jpeg
mkdir jpeg
for i in *.jpg; do ffmpeg -i $i jpeg/$(basename $i .jpg).jpeg; done


## 1.5/ Rotate images if necessary
## For example: Rotate 90 degrees(CW)
mkdir 90
for i in jpeg/*.jpeg; do convert $i -rotate 90 90/$(basename $i); done



## 2/ Convert set of images to a single pdf file
img2pdf --output tmp1.pdf -S A4 jpeg/*.jpeg
## or
img2pdf --output tmp1.pdf -S A4 90/*.jpeg

## 3/ Add document info page
## Download and edit https://github.com/archandanime/Arch-files/blob/master/Procedure/papers2pdf-infopage.odt
wget https://github.com/archandanime/Arch-files/raw/master/Procedure/papers2pdf-infopage.odt
## Merge pdf
pdftk tmp1.pdf scanned-document-info.pdf cat output done.pdf
