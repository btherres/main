#!/bin/bash

# 2011 by Bastian Therres
# licensed under CC-BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/)
#
# Garfield by Jim Davis - (c) 2011 Paws, Inc.
# Daily Strip at http://www.gocomics.com/garfield/
# 
# Description: This is a small script to download the last X comic strips of the daily garfield comic via curl
# Usage: getGarfield.sh [number of days] [/path/to/downloadfolder/]

#RANGEOFDAYS=$1
#FOLDERTOSAVE=$2
COUNTER=0

if [ $1 -eq $1 2> /dev/null ]; then
    echo Loading last $1 strips...
else
    echo ERROR: $1 is not a number
    exit
fi

if [ ! -d "$2" ]; then
    echo ERROR: $2 is not a directory
    exit
fi

while [ ${COUNTER} -le $1 ]
        do
        URL=http://images.ucomics.com/comics/ga/$(date -v-${COUNTER}d +%Y)/ga$(date -v-${COUNTER}d +%y%m%d).gif
        if [ ! -f $2/ga$(date -v-${COUNTER}d +%Y%m%d).gif ]; then
            curl -# -f $URL -o $2/ga$(date -v-${COUNTER}d +%y%m%d).gif
            
            if [ $? -eq 0 ]
                then
                mv $2/ga$(date -v-${COUNTER}d +%y%m%d).gif $2/ga$(date -v-${COUNTER}d +%Y%m%d).gif
            fi
        fi
        COUNTER=`expr ${COUNTER} + 1`
done