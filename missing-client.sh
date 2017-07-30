#!/bin/bash
IFS=$(echo -en "\n\b")

FILE=/tmp/protected_client.txt
if [ ! -f $FILE ]
then
	client_list=$(mccli client show --recursive=true | grep -i /$(cat /usr/local/vdr/etc/vcenterinfo.cfg | grep vcenter-hostname | cut -d '=' -f 2)/VirtualMachines | awk -F/ '{print $(NF-2)}')
	echo "$client_list" &> /tmp/protected_client.txt
	sort /tmp/protected_client.txt -o /tmp/protected_client.txt
else
	new_list=$(mccli client show --recursive=true | grep -i /$(cat /usr/local/vdr/etc/vcenterinfo.cfg | grep vcenter-hostname | cut -d '=' -f 2)/VirtualMachines | awk -F/ '{print $(NF-2)}')
	echo "$new_list" &> /tmp/new_list.txt
	sort /tmp/new_list.txt -o /tmp/new_list.txt
	missing=$(comm  -3 /tmp/protected_client.txt /tmp/new_list.txt | sed 's/^ *//g') 
	if [ -z "$missing" ] 
	then
		printf "\nNo Client's missing\n"
	else
		printf "\nMissing Client is:\n" | tee -a /tmp/email_list.txt
		printf "$missing\n\n" | tee -a /tmp/email_list.txt
		printf "Emailing the list\n"
		
		FILE=/tmp/email_list.txt
		read -p "Enter Your Email: " TO
		FROM=admin@$(hostname)
		
(cat - $FILE)<< EOF | /usr/sbin/sendmail -f $FROM -t $TO
Subject: Missing VMs from Jobs
To: $TO
EOF
	sleep 2s
	printf "\nEmail Sent. Exiting Script\n\n"
	fi
	rm /tmp/new_list.txt
	rm -f /tmp/email_list.txt
fi



