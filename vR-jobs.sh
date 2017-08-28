#!/bin/bash
clear

cd /opt/vmware/vpostgres/9.*/bin
echo "Backing VRMS Database under /tmp"
./pg_dump -U vrmsdb -Fp -c > /tmp/DBBackup.bak 
echo

echo -e " ------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "|     Virtual Machine              |   Network Compression   |  Quiesce   |   RPO     |  Datastore MoRef ID |         Datastore UUID             |"
echo -e " ------------------------------------------------------------------------------------------------------------------------------------------------"

./psql -U vrmsdb << EOF
\o /tmp/info.txt
select name from groupentity;
select networkcompressionenabled from groupentity;
select rpo from groupentity;
select quiesceguestenabled from groupentity;
select configfilesdatastoremoid from virtualmachineentity;
select destconfigfilesdatastoreuuid from virtualmachineentity;
EOF

cd /tmp
touch format-output.txt
name_array=($(awk '/name/{i=1;next}/ro*/{i=0}{if (i==1){i++;next}}i' info.txt))
quiesce_array=($(awk '/networkcompressionenabled/{i=1;next}/ro*/{i=0}{if (i==1){i++;next}}i' info.txt))
compression_array=($(awk '/quiesceguestenabled/{i=1;next}/ro*/{i=0}{if (i==1){i++;next}}i' info.txt))
rpo_array=($(awk '/rpo/{i=1;next}/ro*/{i=0}{if (i==1){i++;next}}i' info.txt))
datastore_array=($(awk '/configfilesdatastoremoid/{i=1;next}/ro/{i=0} {if (i==1){i++;next}}i' info.txt))
datastore_uuid=($(awk '/destconfigfilesdatastoreuuid/{i=1;next}/ro*/{i=0} {if (i==1){i++;next}}i' info.txt))

length=${#name_array[@]}
for ((i=0;i<$length;i++));
do
		printf "| %-32s | %-23s | %-10s | %-10s| %-20s| %-34s|\n" "${name_array[$i]}" "${quiesce_array[$i]}" "${compression_array[$i]}" "${rpo_array[$i]}" "${datastore_array[$i]}" "${datastore_uuid[$i]}"
done

rm -f info.txt
echo && echo
