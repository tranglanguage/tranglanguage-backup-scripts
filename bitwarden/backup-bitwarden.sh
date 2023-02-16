#!/bin/bash
DIR=$( dirname -- $0; )
cd $DIR

./bitwarden.sh stop
BACKUPNAME=$DIR/$(date +%F_%H-%M-%S).zip
zip -r $BACKUPNAME bwdata -x bwdata/mssql/backups/**\* bwdata/letsencrypt/**\*
/snap/bin/gcloud storage cp $BACKUPNAME gs://btwrdn-backup/
rm -rf $BACKUPNAME
./bitwarden.sh start
