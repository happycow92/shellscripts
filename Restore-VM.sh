#!/bin/bash
clear
IFS=$(echo -en "\n\b")

vcenter_name=$(grep vcenter-hostname /usr/local/vdr/etc/vcenterinfo.cfg | awk -F '=' '{print $2}')
printf "\nThese are the list of clients\n"
echo "$(mccli client show --recursive=true | grep /VirtualMachines | awk -F "/" '{print $(NF-2)}')"
echo
read -p "Which virtual machine would you like to list the backups?: " machine_name
printf "\nHere is the list of backups for $machine_name\n"
echo "$(mccli backup show --name=/$vcenter_name/VirtualMachines/$machine_name --recursive=true | tail -n +2)"
echo
read -p "Is this a Windows VM or a Linux VM?: " vm_type

if [ "$vm_type" == "Linux" ] || [ "$vm_type" == "linux" ]
then
	plugin=1016
elif [ "$vm_type" == "Windows" ] || [ "$vm_type" == "windows" ]
then
	plugin=3016
else
	printf "\nInvalid choice. Exiting\n\n"
	exit 1;
fi
echo
read -p "Which label number do you want to restore the VM from?: " label_num
read -p "Enter the DataCenter Name (Case Sensitive): " data_center
read -p "Enter the Folder name (Case Sensitive): " folder_name
read -p "Enter a name for the Restored Virtual Machine: " new_name
read -p "Enter the FQDN or IP of ESX where this restored VM sould reside: " esx_host
read -p "Enter the datastore name where VM Files should be (Case Sensitive): " datastore_name

printf "\nPerforming the restore\n"
echo && echo
mccli backup restore --name=/$vcenter_name/VirtualMachines/$machine_name  --labelNum=$label_num --restore-vm-to=new --virtual-center-name=$vcenter_name --datacenter=$data_center --folder=$folder_name --dest-client-name=$new_name --esx-host-name=$esx_host --datastore-name=$datastore_name --plugin=$plugin
if [ $? -eq 0 ]
then
	printf "\nMonitor restore using \'watch -d -n 10 mccli activity show --active\'\n"
else
	exit
fi
