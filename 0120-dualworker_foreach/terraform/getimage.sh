#!/bin/bash -x
#
#https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

#
# Actually downloaded with:
if [ -e "jammy-server-cloudimg-amd64.img" ]; then
   echo Already there
else
    curl https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
        --output jammy-server-cloudimg-amd64.img
fi
#
# Converted the raw image into a qcow
# This will ID the type, need to script this ; qemu-img info jammy-server-cloudimg-amd64.img 
#qemu-img convert -f raw -O qcow2 jammy-server-cloudimg-amd64.img jammy-server-cloudimg-amd64.qcow2
#

# delete the qcow2 if present
if [ -e jammy-server-cloudimg-amd64.qcow2 ]; then
   rm jammy-server-cloudimg-amd64.qcow2
fi
cp jammy-server-cloudimg-amd64.img   jammy-server-cloudimg-amd64.qcow2
cp jammy-server-cloudimg-amd64.qcow2 ubuntu-2204base.qcow2
cp jammy-server-cloudimg-amd64.qcow2 ubuntu-master.qcow2
cp jammy-server-cloudimg-amd64.qcow2 ubuntu-worker.qcow2
#
# Increase the master size by 5GB
qemu-img resize ubuntu-master.qcow2 +5G
qemu-img resize ubuntu-worker.qcow2 +5G
