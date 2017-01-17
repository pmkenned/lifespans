#!/usr/bin/bash

ptm="patch3.js"

prev_txt=""
first=1
for arg in "$@"
do
    file=$arg
    l=${#file}
    base=${file:0:$l-4}

    echo $file...
    
    png=$base.png
    bmp=$base.bmp
    txt=$base.txt
    #ptm=$base.ptm

    #magick $png -flatten -type TrueColor $bmp
    magick $png -type TrueColor $bmp
    ./bmp.exe $bmp > $txt
    if [ $first -eq 1 ];
    then
        ./diff2.pl $txt > $ptm
        echo "var patch = [" >> $ptm
    else
        ./diff.pl $prev_txt $txt >> $ptm
    fi


    first=0
    prev_txt=$txt
done

echo "];" >> $ptm
