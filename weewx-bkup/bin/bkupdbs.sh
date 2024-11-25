#!/bin/bash
#
# Backup all database files and upload to an S3 buckee. 
#
# This can be run manually but is intended to run as cronjob nightly as
#   /home/weewx/weewx-bkup/bin/weewx-bkup >>/home/weewx/weewx-bkup/log/bkup.log 2>&1 
#
# S3 bucket with offsite backup
BUCKETNAME=backups.wmadill.com
# Backups location -- note trailing slash!
BKUPDIR=/home/weewx/weewx-bkup/archive/
# Database(s) location
DBSDIR=/home/weewx/weewx-data/archive/
# Backup name
TARNAME=databases_`date '+%Y-%m-%d_%H%M'`.tar.gz
FULLPATHTAR=$BKUPDIR$TARNAME 

# Day of week (0 = Sunday)
DOW=`date '+%w'`
# Day of month (1 = first day)
DOM=`date '+%-d'`

# Maximum number of daily backups to keep
MAXDLY=100
# Maximum number of weekly backups to keep
MAXWKLY=30
# Maximum number of monthly backups to keep
MAXMNLY=24
# Save daily backup also in "weekly" on Saturday
SAVWKLY=6
# Save daily backup also in "monthly" on first day of month
SAVMNLY=1

echo
echo 'WeeWX database backup at ' `date`

#echo $BUCKETNAME
#echo 'BKUPDIR: ' $BKUPDIR
#echo 'DBSDIR: ' $DBSDIR
#echo 'TARNAME: ' $TARNAME
#echo 'MAXDLY: ' $MAXDLY
#echo 'MAXWKLY: ' $MAXWKLY
#echo 'MAXMNLY: ' $MAXMNLY
#echo 'Full path tar name: ' $FULLPATHTAR
#echo 'SAVWKLY: ' $SAVWKLY
#echo 'DOW:' $DOW
#echo 'SAVMNLY: ' $SAVMNLY
#echo 'DOM:' $DOM

cd $DBSDIR
# the tarball ...
echo 'Creating backup' $TARNAME
tar czf $FULLPATHTAR *.sdb

cd $BKUPDIR

# If weekly save day, copy tarball to "weekly" directory ...
if [ "$DOW" -eq "$SAVWKLY" ]
then
  echo 'Save daily to weekly'
  cp $TARNAME weekly

  # Check if more dailies than maximum desired ...
  CNTDAILY=`ls databases* -1 | wc -l`
  #echo 'CNTDAILY: ' $CNTDAILY
  DELDAILY=$((CNTDAILY-MAXDLY))
  echo 'DELDAILY: ' $DELDAILY
  
  # and delete oldest ones
  if [ "$DELDAILY" -gt 0 ]
  then
    echo 'Deleting these dailies:'
    ls -1r databases* | tail -n $DELDAILY
    ls -1r databases* | tail -n $DELDAILY | xargs rm
  else
    echo 'No dailies to delete'
  fi
else
  echo 'Not weekly save day'
fi

# If monthly save day, copy tarball to "monthly" directory ...
if [ "$DOM" -eq "$SAVMNLY" ]
then
  echo 'Save daily to monthly'
  cp $TARNAME monthly

  # Check if more weeklies than maximum desired ...
  cd weekly
  CNTWKLY=`ls databases* -1 | wc -l`
  #echo 'CNTWKLY: ' $CNTWKLY
  DELWKLY=$((CNTWKLY-MAXWKLY))
  echo 'DELWKLY: ' $DELWKLY
  
  # and delete oldest ones
  if [ "$DELWKLY" -gt 0 ]
  then
    echo 'Deleting these weeklies:'
    ls -1r databases* | tail -n $DELWKLY
    ls -1r databases* | tail -n $DELWKLY | xargs rm
  else
    echo 'No weeklies to delete'
  fi

  # Check if more monthlies than maximum desired ...
  cd ../monthly
  CNTMNLY=`ls databases* -1 | wc -l`
  #echo 'CNTMNLY: ' $CNTMNLY
  DELMNLY=$((CNTMNLY-MAXMNLY))
  echo 'DELMNLY: ' $DELMNLY
  
  # and delete oldest ones
  if [ "$DELMNLY" -gt 0 ]
  then
    echo 'Deleting these monthlies'
    ls -1r databases* | tail -n $DELMNLY 
    ls -1r databases* | tail -n $DELMNLY | xargs rm
  else
    echo 'No monthlies to delete'
  fi
else
  echo 'Not monthly save day'
fi

# and finally the upload!
echo 's3cmd output'
/home/weewx/weewx-venv/bin/s3cmd --config=/home/weewx/.s3cfg sync --delete-removed --skip-existing $BKUPDIR s3://$BUCKETNAME/test-dbs/
