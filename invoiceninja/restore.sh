#!/bin/bash
echo "Restoring invoiceninja from $1..."

DIR=$( dirname -- $0; )
cd $DIR

echo "Cloning invoiceninja from github..."
git clone https://github.com/invoiceninja/dockerfiles.git .
chmod 755 docker/app/public
sudo chown -R 1500:1500 docker/app

GCP_CLI_EXISTS=$(snap list | grep -c google-cloud-cli)
if [[ $GCP_CLI_EXISTS == 0 ]]; then
  echo "Installing gcloud..."
  snap remove google-cloud-sdk
  snap install google-cloud-cli --classic
  gcloud init --project=tranglanguage-backup --skip-diagnostics
fi

echo "Checking backup file $1 from GCP..."
FILEPATH=gs://tranglanguage-billing-backup/$1
gcloud storage ls $FILEPATH
FILE_EXISTS=$?

if [[ $FILE_EXISTS == 1 ]]; then
  echo "$1 not found on the storage account. Exiting..."
  rm -rf *
  exit 1
fi

if ! [[ -x "$(command -v docker)" ]]; then
    echo "Installing docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

echo "Downloading backup file $1 from GCP..."
gcloud storage cp $FILEPATH $1
unzip -o $1
docker compose up -d

echo "Enabling cronjob for future backup..."
systemctl enable cron
crontab -l | { cat; echo "0 1,9,17 * * * $(pwd)/backup.sh >/dev/null 2>&1"; } | crontab -

echo "Cleaning..."
rm -f $1
rm -f get-docker.sh
rm -f restore.sh
echo "Completed."
