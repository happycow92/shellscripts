#!/bin/bash
clear
IFS=$(echo -en "\n\b")

echo "This script should be executed on a proxy machine"
echo "Checking current Machine......"

directory="/usr/local/vdr"
if [ ! -d "$directory" ]
then
        printf "Current machine is Proxy machine"
else
        printf "Current machine is VDP Server"
fi

echo && echo
sleep 2s
echo -e "--------------------------------------------------------"
echo -e "| Client Name          | Backup Type |    Proxy Used    |"
echo -e "--------------------------------------------------------"

cd /usr/local/avamarclient/var
backupLogList=$(ls -lh | grep -i "vmimagew.log\|vmimagel.log" | awk '{for (i=1; i<=8; i++)  $i=""; print $0}' | sed 's/^ *//')

for i in $backupLogList
do
                clientName=$(cat $i | grep -i "<11982>" | awk '{print $NF}' | cut -d '/' -f 1)
                protocolType=$(cat $i | grep -i "<9675>" | awk '{print $7}' | head -n 1)
                proxyName=$(cat $i | grep -i "<11979>" | cut -d ',' -f 2)
                if [ "$protocolType" == "hotadd" ]
                then
                                protocol="hotadd"
                elif [ "$protocolType" == "nbdssl" ]
                then
                                protocol="nbdssl"
                elif [ "$protocolType" == "nbd" ]
                then
                                protocol="nbd"
                else
                                protocol="SAN Mode"
                fi

                printf "| %-20s| %14s| %12s|\n" "$clientName" "$protocolType" "$proxyName"
done

echo && echo
