#!/usr/bin/env sh
set -e -x

ZONE=europe-west1-b
DISK_SIZE=200GB
DEFAULT_STARTUP=https://raw.githubusercontent.com/FlorentFlament/pcf-tools/master/pcfbox-setup.bash
OPTS=""

# If an argument is provided, use it as a startup file
if [ $# -gt 0 ]; then
    STARTUP_FILE=$1
    OPTS="$OPTS --metadata-from-file=startup-script=$STARTUP_FILE"
else
    OPTS="$OPTS --metadata=startup-script-url=$DEFAULT_STARTUP"
fi

gcloud compute instances create pcfbox \
       --zone=$ZONE \
       --image-project=ubuntu-os-cloud \
       --image-family=ubuntu-1604-lts \
       --boot-disk-size=$DISK_SIZE \
       $OPTS
