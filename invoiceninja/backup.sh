#!/bin/bash
DIR=$( dirname -- $0; )
cd $DIR

APPURL=$(cat env | grep APP_URL= | cut -d '=' -f2)
APPENV=$(cat env | grep APP_ENV= | cut -d '=' -f2)
APPDEBUG=$(cat env | grep APP_DEBUG= | cut -d '=' -f2)

if [[ $APPURL != "https://billing.tranglanguage.com" || $APPENV != "production" || $APPDEBUG != "false" ]]; then
    echo "Prod env not detected. Exiting..."
    exit
fi

BACKUPNAME=$DIR/$(date +%F_%H-%M-%S).zip

docker compose down
zip -r $BACKUPNAME docker/app/public/storage docker/mysql/data docker-compose.yml env
/snap/bin/gcloud storage cp $BACKUPNAME gs://tranglanguage-billing-backup/
rm -rf $BACKUPNAME
docker compose up -d
