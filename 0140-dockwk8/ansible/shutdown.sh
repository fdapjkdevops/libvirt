#!/bin/bash -x
#virsh shutdown k8master
#virsh shutdown k8worker1
#virsh shutdown k8worker2
for i in worker1 worker2 master
do
	ssh $i sudo shutdown -h 1
done

