#!/bin/bash
#scp copy2vm/50-cloud-init.conf root@192.168.122.234:/etc/ssh/sshd_config.d/50-cloud-init.conf
#scp copy2vm/nopass.lst         root@192.168.122.234:/etc/sudoers.d/nopass.lst
while read value
do
	echo -n Processing $value...
	scp copy2vm/50-cloud-init.conf root@$value:/etc/ssh/sshd_config.d/50-cloud-init.conf >/dev/null
        if [ $? -eq 0 ];
        then
	   scp copy2vm/NOPASSWD        root@$value:/etc/sudoers.d/NOPASSWD >/dev/null
	   if [ $? -eq 0 ];
           then
              echo Success
	   else
              echo Failed on nopass
	   fi
	else
	   echo Unable to copy 50-cloud
	fi
done < ipvalues.txt

