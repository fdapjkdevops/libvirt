#!/bin/bash 
# Below will get the mac address of master and place into $themac
#themac=$(virsh dumpxml master | grep "mac address" | awk -F\' ' { print $2}')
namelist="k8master k8worker1 k8worker2"
namebaselist="master worker1 worker2"
#echo "My array: $arr"
#echo "Number of elements in the array: ${#arr[@]}"
arr=([0]='master' [1]="worker1" [2]="worker2")
read -r -a arr <<< "$namebaselist"
#echo "My array: $arr"
#echo "Number of elements in the array: ${#arr[@]}"
#echo 0=${arr[0]}
#echo 1=${arr[1]}
#echo 2=${arr[2]}
rm -f macaddresses
rm -f ipvalues.txt
rm -f ../ansible/hosts
cp ../ansible/hosts.template ../ansible/hosts > /dev/null
cp ../ansible/etchosts.template ../ansible/etchosts > /dev/null
touch macaddresses
touch macaddresses
i=0
for name in $namelist; do
   bname=${arr[$i]}
   ((i=i+1))
   mac=$(virsh dumpxml $name | grep "mac address" | awk -F\' ' { print $2}') 
   #output the vm name and the macaddress
   echo VM: $name, MAC Addr: $mac >>macaddresses
   ipline=$(arp -an | grep $mac)
   ip="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$ipline")"
   echo IP Address for $name is: $ip
   echo $ip >>ipvalues.txt
   uname={{${bname^^}IP}}
   substr=s/$uname/$ip/g
#   echo uname: $uname -\> $ip
#   echo substr: $substr
   sed -i $substr ../ansible/hosts
   sed -i $substr ../ansible/etchosts
done



