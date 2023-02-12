./bitwarden.sh stop
BACKUPNAME=$(date +%F_%H-%M-%S).zip
zip -r $BACKUPNAME bwdata -x bwdata/mssql/backups/**\* bwdata/letsencrypt/**\*
gcloud storage cp $BACKUPNAME gs://btwrdn-backup/
rm -rf $BACKUPNAME
./bitwarden.sh start
