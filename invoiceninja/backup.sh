#!/bin/bash
DIR=$( dirname -- $0; )
cd $DIR

BACKUPNAME=$DIR/$(date +%F_%H-%M-%S).zip

docker compose down
zip -r $BACKUPNAME docker/app/public/storage docker/mysql/data docker-compose.yml env
/snap/bin/gcloud storage cp $BACKUPNAME gs://tranglanguage-billing-backup/
rm -rf $BACKUPNAME
docker compose up -d
