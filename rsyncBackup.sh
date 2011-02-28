#!/bin/bash

# Simple backup with rsync
# SOURCES and TARGET must end with slash (e.g. /path/to/backup/ )

SOURCES="/source1/ /source2/ /source3/"
TARGET="/target/"
MOUNTPOINT=""
LOGFILE="/path/to.log"
EXPIREDAYS=30
RSYNC="--delete"

#SSHUSER="user"
#SSHHOST="hostname"
#SSHPORT=22

date > $LOGFILE
MOUNTED=$( mount | fgrep "$MOUNTPOINT");

if [ -z "$MOUNTPOINT" ] || [ -n "$MOUNTED" ]; then

  if [ -e $TARGET ]; then
   LASTBACKUP=$( ls -d $TARGET[[:digit:]]* 2>> $LOGFILE | sort -r | head -1) 
  fi

  TODAY=$(date +%y%m%d)

  if [ $EXPIREDAYS -gt 0  ]; then
    EXPIRED=$(find $TARGET[[:digit:]]* -maxdepth 0 -ctime +$EXPIREDAYS  2>> $LOGFILE)
    for EX in $(echo $EXPIRED)
    do
      echo  "rm -rf $EX " >> $LOGFILE
      rm -rf $EX
    done
  fi

  for SOURCE in $(echo $SOURCES)
  do
    if [ "$LASTBACKUP" ]; then
      INC="--link-dest=$LASTBACKUP$SOURCE"
    fi
    if [ "$SSHUSER" ] && [ "$SSHHOST" ] && [ "$SSHPORT" ]; then
      SSH="ssh -p $SSHPORT -l $SSHUSER";
      SOURCEDIR="$SSHHOST:$SOURCE";
    else
      SOURCEDIR=$SOURCE;
    fi
    /bin/mkdir -p $TARGET$TODAY$SOURCE >> $LOGFILE
    echo "rsync -e \"$SSH\" -av $SOURCEDIR $RSYNC $INC $TARGET$TODAY$SOURCE "  >> $LOGFILE 2>> $LOGFILE;
    rsync -e "$SSH" -av $SOURCEDIR $RSYNC $INC $TARGET$TODAY$SOURCE  >> $LOGFILE 2>> $LOGFILE;
  done
else
  echo "$MOUNTPOINT not mounted" >> $LOGFILE
fi