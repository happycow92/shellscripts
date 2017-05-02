#!/bin/bash
echo -e "***************************************"
echo -e "* This script is written by Suhas G  *"
echo -e "*          gsuhas@vmware.com          *"
echo -e "***************************************"
echo -e "This script fixes vCenter certificate parameter for proxy\n"
echo -e "The current value for ignore_vc_cert is\n"
value=$(cat /usr/local/avamar/var/mc/server_data/prefs/mcserver.xml | grep ignore_vc_cert | cut -d = -f 3 | cut -d " " -f 1)
echo $value
read -p "Proceed with fix?: " choice

case "$choice" in
y|Y )
sed -i -e 's/entry key="ignore_vc_cert" value="false"/entry key="ignore_vc_cert" value="true"/g'  /usr/local/avamar/var/mc/server_data/prefs/mcserver.xml
echo -e "\nThe new value for ignore_vc_cert is"
value=$(cat /usr/local/avamar/var/mc/server_data/prefs/mcserver.xml | grep ignore_vc_cert | cut -d = -f 3 | cut -d " " -f 1)
echo $value
echo -e "\nProceeding to restart MCS"
mcserver.sh --restart --verbose
echo -e "\nProceeding to re-register internal proxy"
sudo /usr/local/avamarclient/etc/initproxy.sh --start
echo -e "\nAll done!";;
n|N )
echo -e "\nExiting script";;
esac

