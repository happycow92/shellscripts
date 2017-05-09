#!/bin/bash

# This block is for help parameters. 
usage()
{
cat << EOF

Below are the available fields

OPTIONS:
   -h      Help
   -a      Active Job
   -w      Waiting Job
EOF
}
# This block saves status of active/waiting-client/waiting-queued backups
value=$(mccli activity show --active | cut -d ' ' -f 1 | sed -e '1,3d')
value_client=$(mccli activity show | grep -i "Waiting-Client" | cut -d ' ' -f 1)
value_queued=$(mccli activity show | grep -i "Waiting-Queued" | cut -d ' ' -f 1)

# This block does a flag input
while getopts "haw" option
do
	case $option in
		a)
		
	if [ -z $value ]
	then
		printf "No active jobs to cancel\n"
	else
	
		printf "Cancelling active jobs\n"
		for i in $value
		do
		mccli activity cancel --id=$i
		done
	
	fi
		;;
		w)
		if [ -z $value_client ]
		then
			echo $value_client
			printf "No jobs in waiting client state\n"
		else
			printf "Cancelling waiting clients\n"	
			for i in $value_client
			do
				mccli activity cancel --id=$i
			done
		fi
		if [ -z $value_queued ]
		then
			printf "No jobs in waiting queued state\n"
		else
			printf "Cancelling queued clients\n"
			for i in $value_queued
			do
				mccli activity cancel --id=$i
			done
		fi
		;;
h)
usage
;;
?)
printf "type -h for list\n"
;;
esac
done
