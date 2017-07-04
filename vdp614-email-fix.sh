#!/bin/bash
clear

echo -e "***************************************************************\n"
echo -e "           This Script Is Written By Suhas G Savkoor           \n"
echo -e "		        gsuhas@vmware.com			\n"
echo -e "***************************************************************\n"
echo

# Connectivity tests

printf "Checking network connectivity\n"
if ping -q -c 1 -W 1 8.8.8.8 &> /dev/null;
then
        printf "Network Good. Proceeding further\n"
else
        printf  "Unable to connect. Apply manually. Exiting script\n"
        exit 1
fi

# Download Fix

printf "\nDownloading the Email patch binaries\n"
wget https://www.dropbox.com/s/b0mfo00jzgegm2e/EMC-CDFB70F537.zip?dl=0 -O /root/Fix.zip &> /dev/null

printf "Download done. Proceeding\n"

# Extracting Zip

cd /root
unzip Fix.zip
md5_original="90a57acb1404cdff68181b6768d3b539"
md5_downloaded=$(cat md5sum.txt | sed -n 2p | awk '{print $1}')

if [ "$md5_original" == "$md5_downloaded" ]
then
	printf "\nMD5 Sum matches. Proceeding further\n"
else
	printf "\nMD5 Sum does not match. Retry download\n"
	exit 1
fi

# File Backup and fix apply

printf "\nStopping tomcat service"
emwebapp.sh --stop $> /dev/null
status=$(emwebapp.sh --test | awk '{print $NF}')
if [ "$status" == "up" ]
then
	printf "\nTomcat still running\n"
	exit 1
else
	printf "\nBacking up original vdr-server.war file to /root\n"
	cp -p /usr/local/avamar/lib/vdr-server.war /root/vdr-server.war_ORIG

	printf "\nApplying the patch\n"
	chmod 755 vdr-server.war
	cp -p /root/vdr-server.war /usr/local/avamar/lib/vdr-server.war

	printf "Clearing tomcat cache\n"
	rm -R /usr/local/avamar-tomcat/webapps/vdr-server*

	printf "\nStarting tomcat service\n"
	emwebapp.sh --start &> /dev/null
	status=$(emwebapp.sh --test | awk '{print $NF}')
	
	if [ "$status" == "up" ]
	then
		printf "Tomcat is up"
		printf "\nFix applied. Exiting Script\n\n\n"
		exit 0
	fi
fi

