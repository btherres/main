#!/bin/bash

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
        
        if [ ! -f $2/ga$(date -v-${COUNTER}d +%y%m%d).gif ]
        then
            curl -f $URL -o $2/ga$(date -v-${COUNTER}d +%y%m%d).gif
        fi
        
        COUNTER=`expr ${COUNTER} + 1`
done