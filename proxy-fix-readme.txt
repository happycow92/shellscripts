This script fixes the Certificate ingore parameter issue in vSphere Data Protection 6.x
Download the proxy-fix.sh script
Place it under /home/admin directory
Provide the script a+x permissions
chmod a+x proxy-fix.sh
Be in "admin" mode of VDP
./proxy-fix.sh to run the script. There are no additional switches available.

This script, replaces ignore_vc_cert parameter to true from false
Restarts MCS service
Re-registers internal proxy to vCenter.