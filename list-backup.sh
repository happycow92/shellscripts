#!/bin/bash

clear

echo -e "-----------------------------------------------------------------------------------------------------------------------"
echo -e "| Client Name               | No. of Backups | Size    | Is Partial | Type    | Storage Type | Data Type  | Last Backup |"
echo -e "-----------------------------------------------------------------------------------------------------------------------"

vcenter_name=$(cat /usr/local/vdr/etc/vcenterinfo.cfg | grep vcenter-hostname | cut -d '=' -f 2)
client_list=$(avmgr getl --path=/$vcenter_name/VirtualMachines | awk '{print $2}' | tail -n+2)
agent_client=$(avmgr getl --path=/clients/VDPApps | grep -v 'SQLAlwaysOn\|SQLFailover\|ExchangeDAG' | tail -n+2 | awk '{print $2}')
base=1073741824

        for i in $client_list
        do

                number_of_backup=$(avmgr getb --path=/$vcenter_name/VirtualMachines/$i | tail -n+2 | wc -l)
                size=$(avmgr getb --path=/$vcenter_name/VirtualMachines/$i --format=xml | sed 's/ /\n/g' | grep totalbytes | head -n 1 | cut -d '=' -f 2 | tr -d '"' | cut -d '.' -f 1)
				sizeInGB=$((size/base))GB
				partial=$(avmgr getb --path=/$vcenter_name/VirtualMachines/$i --format=xml | sed 's/ /\n/g' | grep partial | cut -d '=' -f 2 | tr -d '"' | head -n 1)
				if [ "$partial" == 0 ]
				then
					type="NO"
				else
					type="YES"
				fi
				pid=$(avmgr getb --path=/$vcenter_name/VirtualMachines/$i --format=xml | sed 's/ /\n/g' | grep pidnum | cut -d '=' -f 2 | tr -d '"' | head -n 1)
				if [ "$pid" == 3016 ] 
				then
					pidType="Windows"
				else
					pidType="Linux"
				fi
				destination=$(avmgr getb --path=/$vcenter_name/VirtualMachines/$i --format=xml | sed 's/ /\n/g' | grep ddrindex | head -n 1 | cut -d '=' -f 2 | tr -d '"')
				if [ "$destination" == 0 ]
				then
					isDD="VDP Storage"
				else
					isDD="Data Domain"
				fi
				
				is_backed=$(avmgr getb --path=/$vcenter_name/VirtualMachines/$i --format=xml | sed -n 4p | grep -o backuplistrec)

				if [ "$is_backed" == "backuplistrec" ]
				then
					date_backed=$(avmgr getb --path=/$vcenter_name/VirtualMachines/$i --format=xml | sed -n 4p | sed 's/ /\n/g' | grep created | head -n 1 | cut -d '=' -f 2 | tr -d '"')
					time=$(t.pl $date_backed | awk '{print $3,$4,$6}')
				else
					time="No Backup"
				fi

                printf "| %-25s | %14s | %7s | %10s | %7s | %12s | %11s| %12s|\n" "$(echo $i | cut -d '_' -f 1)" "$number_of_backup" "$sizeInGB" "$type" "$pidType" "$isDD" "Backup" "$time"
        done
		
		for x in $agent_client
		do	
			number_of_backup=$(avmgr getb --path=/clients/VDPApps/$x --format=xml | tail -n+2 | wc -l)
			size=$(avmgr getb --path=/clients/VDPApps/$x --format=xml | sed 's/ /\n/g' | grep totalbytes | head -n 1 | cut -d '=' -f 2 | tr -d '"' | cut -d '.' -f 1)
			sizeInGB=$((size/base))GB
				partial=$(avmgr getb --path=/clients/VDPApps/$x --format=xml | sed 's/ /\n/g' | grep partial | cut -d '=' -f 2 | tr -d '"' | head -n 1)
				if [ "$partial" == 0 ]
				then
					type="NO"
				else
					type="YES"
				fi
			destination=$(avmgr getb --path=/clients/VDPApps/$x --format=xml | sed 's/ /\n/g' | grep ddrindex | head -n 1 | cut -d '=' -f 2 | tr -d '"')
			if [ "$destination" == 0 ]
				then
					isDD="VDP Storage"
				else
					isDD="Data Domain"
			fi
			
			is_backed=$(avmgr getb --path=/clients/VDPApps/$x --format=xml | sed -n 4p | grep -o backuplistrec)

				if [ "$is_backed" == "backuplistrec" ]
				then
					date_backed=$(avmgr getb --path=/clients/VDPApps/$x --format=xml | sed -n 4p | sed 's/ /\n/g' | grep created | head -n 1 | cut -d '=' -f 2 | tr -d '"')
					time=$(t.pl $date_backed | awk '{print $3,$4,$6}')
				else
					time="No Backup"
				fi

			printf "| %-25s | %14s | %7s | %10s | %7s | %12s | %11s| %12s|\n" "$(echo $x)" "$number_of_backup" "$sizeInGB" "$type" "Agent" "$isDD" "Backup" "$time"
		done
		
		replicate_vdp=$(avmgr getl --path=/REPLICATE | sed -n 2p | awk '{print $2}')
		replicate_vcenter=$(avmgr getl --path=/REPLICATE/$replicate_vdp |  awk '{print $2}' | grep -v 'Request\|clients\|MC_DELETED\|MC_RETIRED\|MC_SYSTEM\|REPLICATE')
		replicate_client=$(avmgr getl --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines | sed -n 2p | awk '{print $2}')
		
		for y in $replicate_client
		do
			
			number_of_replication=$(avmgr getb --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines/$y --format=xml | tail -n+2 | wc -l)
			size=$(avmgr getb --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines/$y --format=xml | sed 's/ /\n/g' | grep totalbytes | head -n 1 | cut -d '=' -f 2 | tr -d '"' | cut -d '.' -f 1)
			sizeInGB=$((size/base))GB
			
			partial=$(avmgr getb --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines/$y --format=xml | sed 's/ /\n/g' | grep partial | cut -d '=' -f 2 | tr -d '"' | head -n 1)
			if [ "$partial" == 0 ]
				then
					type="NO"
				else
					type="YES"
				fi
			destination=$(avmgr getb --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines/$y --format=xml | sed 's/ /\n/g' | grep ddrindex | head -n 1 | cut -d '=' -f 2 | tr -d '"')
			if [ "$destination" == 0 ]
				then
					isDD="VDP Storage"
				else
					isDD="Data Domain"
			fi
			pid=$(avmgr getb --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines/$y --format=xml | sed 's/ /\n/g' | grep pidnum | cut -d '=' -f 2 | tr -d '"' | head -n 1)
			if [ "$pid" == 3016 ] 
				then
					pidType="Windows"
				else
					pidType="Linux"
				fi
				
			is_backed=$(avmgr getb --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines/$y --format=xml | sed -n 4p | grep -o backuplistrec)

				if [ "$is_backed" == "backuplistrec" ]
				then
					date_backed=$(avmgr getb --path=/REPLICATE/$replicate_vdp/$replicate_vcenter/VirtualMachines/$y --format=xml | sed -n 4p | sed 's/ /\n/g' | grep created | head -n 1 | cut -d '=' -f 2 | tr -d '"')
					time=$(t.pl $date_backed | awk '{print $3,$4,$6}')
				else
					time="No Backup"
				fi
				
			printf "| %-25s | %14s | %7s | %10s | %7s | %12s | %11s| %12s|\n" "$(echo $y | cut -d '_' -f 1)" "$number_of_replication" "$sizeInGB" "$type" "$pidType" "$isDD" "REPLICATION" "$time"
		done

echo && printf "For Bugs and Feature Requests, email gsuhas@vmware.com"			
echo && echo

