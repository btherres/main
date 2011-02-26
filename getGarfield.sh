#!/bin/bash

#RANGEOFDAYS=$1
#FOLDERTOSAVE=$2
COUNTER=0


while [ ${COUNTER} -le $1 ]
        do
        URL=http://images.ucomics.com/comics/ga/$(date -v-${COUNTER}d +%Y)/ga$(date -v-${COUNTER}d +%y%m%d).gif
        curl $URL -o $2/ga$(date -v-${COUNTER}d +%y%m%d).gif        
        COUNTER=`expr ${COUNTER} + 1`
done