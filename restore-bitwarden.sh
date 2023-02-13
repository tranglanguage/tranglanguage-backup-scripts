#!/bin/bash
echo "Restoring bwdata from $1"
GCP_CLI_EXISTS=$(snap list | grep -c google-cloud-cli)
if [[ $GCP_CLI_EXISTS == 0 ]]; then
  echo "Installing gcloud..."
  snap remove google-cloud-sdk
  snap install google-cloud-cli --classic
  gcloud init --project=tranglanguage-backup --skip-diagnostics
fi

FILEPATH=gs://btwrdn-backup/$1
gcloud storage ls $FILEPATH
FILE_EXISTS=$?

if [[ $FILE_EXISTS == 1 ]]; then
  echo "$1 not found on the storage account. Exiting..."
  exit 1
fi

DIR=$( dirname -- $0; )
cd $DIR

if ! [[ -x "$(command -v docker)" ]]; then
    echo "Installing docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

curl -Lso bitwarden.sh https://go.btwrdn.co/bw-sh && chmod 700 bitwarden.sh
gcloud storage cp $FILEPATH $1
unzip $1
./bitwarden.sh start

systemctl enable cron
crontab -l | { cat; echo "0 1,9,17 * * * $(pwd)/backup-bitwarden.sh >/dev/null 2>&1"; } | crontab -

rm $1
rm -f get-docker.sh
rm restore-bitwarden.sh
