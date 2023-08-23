#!/bin/bash -x
cp jammy-server-cloudimg-amd64.qcow2 /var/lib/libvirt/images/ubuntu-2204base.qcow2
cp ubuntu-master.qcow2               /var/lib/libvirt/images/ubuntu-master.qcow2
cp ubuntu-worker.qcow2               /var/lib/libvirt/images/ubuntu-worker.qcow2

