#!/bin/bash

# Version 1 of script
# Lists out backup job details and replication job details


clear
IFS=$(echo -en "\n\b")

echo -e " ----------------------------------------------------------------------------------------------------------------------------------"
echo -e "| Job  Name                      | Enabled | Client Names            | Retention          | Schedule of Job         | Type         |"
echo -e " ----------------------------------------------------------------------------------------------------------------------------------"

vcenter_name=$(cat /usr/local/vdr/etc/vcenterinfo.cfg | grep vcenter-hostname | cut -d '=' -f 2)
job_name=$(mccli group show --recursive=true | grep -i "/$vcenter_name/VirtualMachines" | awk -F/. '{print $(NF-2)}')

for i in $job_name
do
	enabled=$(mccli group show --name=/$vcenter_name/VirtualMachines/$i | grep Enabled | awk '{print $NF}')
	client_name=$(mccli group show-members --name=/$vcenter_name/VirtualMachines/$i | grep -Po '.*/\K.*' | awk 'NF{NF-=2};1')
	for j in $client_name
	do
		basic=$(mccli retention show --name=/$vcenter_name/VirtualMachines/$i | grep -Po '.*Date.*' | awk '{print $NF}')
		if [ "$basic" == "days" ]
		then
			basic_backup=$(mccli retention show --name=/$vcenter_name/VirtualMachines/$i | grep -Po '.*Date.*' | awk '{print $(NF-1)}')
			when=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Repeat" | awk '{print $NF}')
			if [ "$when" == "Daily" ]
			then
				time=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				sched=$when" "$time
				type=$(mccli dataset show --name=/$vcenter_name/VirtualMachines/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$basic_backup" "$sched" "$type"
			else
				time=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				date=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i | grep -A1 Repeat | grep -v "Repeat" | awk '{print $NF}')
				sched=$when" "$time" "$date
				type=$(mccli dataset show --name=/$vcenter_name/VirtualMachines/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$basic_backup" "$sched" "$type"
			fi
		elif [ "$basic" == "type" ]
		then
			daily=$(mccli retention show --name=/$vcenter_name/VirtualMachines/$i | tail -n +4 | grep -v "Name\|Domain\|Override" | grep Daily | awk '{print $NF}')
			weekly=$(mccli retention show --name=/$vcenter_name/VirtualMachines/$i | tail -n +4 | grep -v "Name\|Domain\|Override" | grep Weekly | awk '{print $NF}')
			Monthly=$(mccli retention show --name=/$vcenter_name/VirtualMachines/$i | tail -n +4 | grep -v "Name\|Domain\|Override" | grep Monthly | awk '{print $NF}')
			Yearly=$(mccli retention show --name=/$vcenter_name/VirtualMachines/$i | tail -n +4 | grep -v "Name\|Domain\|Override" | grep Yearly | awk '{print $NF}')
			custom="$daily"-D,"$weekly"-W,"$Monthly"-M,"$Yearly"-Y
			when=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Repeat" | awk '{print $NF}')
			if [ "$when" == "Daily" ]
			then
				time=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				sched=$when" "$time
				type=$(mccli dataset show --name=/$vcenter_name/VirtualMachines/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$custom" "$sched" "$type"
			else
				time=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				date=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i | grep -A1 Repeat | grep -v "Repeat" | awk '{print $NF}')
				sched=$when" "$time" "$date
				type=$(mccli dataset show --name=/$vcenter_name/VirtualMachines/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$custom" "$sched" "$type"
			fi
		else
			advanced_ret=$(mccli retention show --name=/$vcenter_name/VirtualMachines/$i | grep -Po '.*Date.*' | awk '{print $NF}')
			when=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Repeat" | awk '{print $NF}')
			if [ "$when" == "Daily" ]
			then
				time=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				sched=$when" "$time
				type=$(mccli dataset show --name=/$vcenter_name/VirtualMachines/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$custom" "$sched" "$type"
			else
				time=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i  | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				date=$(mccli schedule show --name=/$vcenter_name/VirtualMachines/$i | grep -A1 Repeat | grep -v "Repeat" | awk '{print $NF}')
				sched=$when" "$time" "$date
				type=$(mccli dataset show --name=/$vcenter_name/VirtualMachines/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$advanced_ret" "$sched" "$type"
			fi
		fi
		i="" && enabled="" && retention="" && sched=""
	done	
	printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "------------------------------" "-------" "-----------------------" "------------------" "-----------------------" "------------"
	printf "\n"
done

replication=$(mccli group show --recursive=true | grep Replication | awk 'NF{NF-=3};1')

if [ -z "$replication" ]
then
	echo "Time is in VDP local time" && echo
	exit 0
else
	for i in $replication
	do
		enabled=$(mccli group show --name=/$i | grep Enabled | awk '{print $NF}')
		client_name=$(mccli group show-members --name=/$i | grep -Po '.*/\K.*' | awk 'NF{NF-=2};1')
		for j in $client_name
		do
			basic_retention=$(mccli retention show --name=/$i | grep "Basic Expiration Date" | cut -d '(' -f 1 | awk '{print $(NF-1) " " $NF}')
			if [ "$basic_retention" == "No change" ]
			then
				when=$(mccli schedule show --name=/$i | grep "Repeat" | awk '{print $NF}')
				time=$(mccli schedule show --name=/$i | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				sched=$when" "$time
				type=$(mccli group show --name=/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$basic_retention" "$sched" "$type"
			else
				daily=$(mccli retention show --name=/$i | grep Daily | awk '{print $NF}')
				weekly=$(mccli retention show --name=/$i | grep Weekly | awk '{print $NF}')
				Monthly=$(mccli retention show --name=/$i | grep Monthly | awk '{print $NF}')
				Yearly=$(mccli retention show --name=/$i | grep Yearly | awk '{print $NF}')
				custom="$daily"-D,"$weekly"-W,"$Monthly"-M,"$Yearly"-Y
				when=$(mccli schedule show --name=/$i | grep "Repeat" | awk '{print $NF}')
				time=$(mccli schedule show --name=/$i | grep "Next Run Time" | awk '{print $(NF-1) " " $NF}')
				sched=$when" "$time
				type=$(mccli group show --name=/$i | grep Type | awk '{print $NF}')
				printf "| %-30s | %7s | %23s | %18s | %23s | %12s |\n" "$i" "$enabled" "$j" "$custom" "$sched" "$type"
			fi
		i="" && enabled="" && retention="" && sched=""
		done
		printf "| %-30s | %7s | %23s | %15s | %23s | %12s |\n" "------------------------------" "-------" "-----------------------" "------------------" "-----------------------" "------------"
		printf "\n"
	done
fi

echo "Time is in VDP local time" && echo