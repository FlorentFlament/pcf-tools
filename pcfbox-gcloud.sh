#!/usr/bin/env sh

ZONE=europe-west1-b
DISK_SIZE=200GB
STARTUP_SCRIPT_URL=https://raw.githubusercontent.com/FlorentFlament/pcf-tools/master/pcfbox-setup.bash

gcloud compute instances create pcfbox \
       --zone=$ZONE \
       --image-project=ubuntu-os-cloud \
       --image-family=ubuntu-1604-lts \
       --boot-disk-size=$DISK_SIZE \
       --metadata=startup-script-url=$STARTUP_SCRIPT_URL
