#!/bin/bash
#    add -x after bash above to echo commands
for i in k8master k8worker1 k8worker2
do 
	virsh start $i
done	
