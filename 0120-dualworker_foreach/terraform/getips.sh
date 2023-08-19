#!/bin/bash
# Below will get the mac address of master and place into $themac
#themac=$(virsh dumpxml master | grep "mac address" | awk -F\' ' { print $2}')
namelist="master worker1 worker2"
rm -f macaddresses
rm -f ipvalues.txt
touch macaddresses
for name in $namelist; do
   mac=$(virsh dumpxml $name | grep "mac address" | awk -F\' ' { print $2}') 
   #output the vm name and the macaddress
   echo VM: $name, MAC Addr: $mac >>macaddresses
   ipline=$(arp -an | grep $mac)
   ip="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$ipline")"
   echo IP Address for $name is: $ip
   echo $ip >>ipvalues.txt
done



