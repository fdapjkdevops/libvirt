#!/bin/bash
#    add -x after bash above to echo commands
for i in master worker1 worker2
do 
	virsh start $i
done	
