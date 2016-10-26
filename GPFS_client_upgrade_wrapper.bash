#!/bin/bash


# This script wraps /net/yum/admin/vendor/IBM/install35_nrg1.sh 
# It will document and attempt to install the GPFS client.
# If the GPFS kernel modules (mmfs26, mmfslinux, and tracedev) refuse to unload,
# a manual installation notification will be emailed to gridadmin.

MYDATE=$(date +"%m-%d-%Y")
LOGFILE=/net/yum/admin/work/matt/logs/NRG1_GPFS_client_upgrade/NRG1_GPFS_upgrade.log
MANUAL_INSTALL=/net/yum/admin/work/matt/logs/NRG1_GPFS_client_upgrade/NRG1_GPFS_upgrade_manual_install_list.txt
INSTALL_SCRIPT=/net/yum/admin/vendor/IBM/install35_nrg1.sh
MAIL_LIST="joeuser@myuser.com joeuser2@myuser.com"
NEW_GPFS_VERSION=3.5.0-15


function verify_no_SGE {
echo >>${LOGFILE}
echo "--------------------------" >>${LOGFILE}
echo "$(hostname -s) : START" >>${LOGFILE}
echo "--------------------------" >>${LOGFILE}
qstat -f -u \* | grep `hostname -s` | grep '0/0'
if [ "$?" -eq 0 ]
 then
  echo "No SGE jobs running on $(hostname -s)" >>${LOGFILE}
  echo "Proceeding with upgrade on $(hostname -s)" >>${LOGFILE}
#  qstat -f -u \* | grep `hostname -s` >>${LOGFILE}
 else
  echo "SGE Jobs still running on $(hostname -s) " >>${LOGFILE}
  echo "Exiting script"  >>${LOGFILE}
  exit
fi
}

function document_config {
echo "Documenting $(hostname -s) config " >>${LOGFILE}
rpm -qa | grep -i gpfs >> ${LOGFILE}
/usr/lpp/mmfs/bin/mmgetstate >> ${LOGFILE}
}

function turn_of_GPFS_reboot {
echo "Turning off GPFS on reboot on $(hostname -s)" >>${LOGFILE}
chkconfig gpfs off >>${LOGFILE}
chkconfig --list | grep gpfs >>${LOGFILE}
}

function verify_gpfs_gplbin {
echo "Verifying correct gpfs.gplbin rpm exist for $(hostname -s) kernel version " >>${LOGFILE}
ls /net/yum/admin/vendor/IBM/CentOS/gpfs.gplbin-$(uname -r)-${NEW_GPFS_VERSION}.x86_64.rpm
if [ "$?" -eq 0 ]
 then
  echo "Correct gpfs.gplbin rpm exists : " >>${LOGFILE}
  ls /net/yum/admin/vendor/IBM/CentOS/gpfs.gplbin-$(uname -r)-${NEW_GPFS_VERSION}.x86_64.rpm >>${LOGFILE}
 else
  echo "gpfs.gplbin rpm doesn't exist for $(uname -r) kernel version on $(hostname -s)" >>${LOGFILE}
fi
}

function GFPS_shutdown {
echo "shutting down GPFS on $(hostname -s)" >>${LOGFILE}
/usr/lpp/mmfs/bin/mmshutdown >> ${LOGFILE}
sleep 2
lsmod | grep -E 'mmfs26|mmfslinux|tracedev'
if [ "$?" -eq 0 ]
 then
  echo "mmfs26, mmfslinux and tracedev kernel modules still loaded after mmshutdown" >>${LOGFILE}
  echo "....attempting to unload them " >>${LOGFILE}
#  GPFS_KILL_PID=$(lsof 2>>/dev/null | grep gpfs | grep bash | awk '{print $2}')
  echo "attempting to kill GPFS bash PID" >>${LOGFILE}
  for I in `lsof 2>>/dev/null | grep gpfs | awk '{print $2}'`
   do
    echo "attempting to kill GPFS PID : ${I}" >>${LOGFILE}
    kill -9 ${I}
   done
fi
sleep 10
/usr/lpp/mmfs/bin/mmshutdown
sleep 2
lsmod | grep -E 'mmfs26|mmfslinux|tracedev'
if [ "$?" -eq 0 ]
  then
   echo "GPFS kernel modules still loaded on $(hostname -s), reboot needed" >>${LOGFILE}
   echo "${MYDATE} : $(hostname -s)" >>${MANUAL_INSTALL}
   /bin/mailx -s "Reboot needed on $(hostname -s) for GPFS installation." ${MAIL_LIST} <<EOM
Manual intervention needed.
GPFS kernel modules failed to unload. 
EOM
   exit
fi
}
function install_GPFS_client {
echo "Running ${INSTALL_SCRIPT} script on $(hostname -s)" >>${LOGFILE}
${INSTALL_SCRIPT} >>${LOGFILE}
echo "Finished running ${INSTALL_SCRIPT} script on $(hostname -s)" >>${LOGFILE}
}

function verify_GPFS_install {
rpm -qa | grep -i gpfs | grep ${NEW_GPFS_VERSION}
if [ "$?" -eq 0 ]
 then
   echo "$(hostname -s) has ${NEW_GPFS_VERSION} rpm's installed" >>${LOGFILE}
   rpm -qa | grep -i gpfs >>${LOGFILE}
   touch /tmp/$(hostname -s)_GPFS_install.txt
 else
   echo "$(hostname -s) doesn't have ${NEW_GPFS_VERSION} rpm's installed" >>${LOGFILE}
fi
sleep 2
GPFS_state=$(/usr/lpp/mmfs/bin/mmgetstate | grep active | awk '{print $3}')
if [ "$GPFS_state" == 'active' ]
 then
   echo "GPFS is active on $(hostname -s)" >>${LOGFILE}
   echo "Done" >/tmp/$(hostname -s)_GPFS_install.txt
 else
   echo "GPFS is not active on $(hostname -s)" >>${LOGFILE}
fi

if [ -s /tmp/$(hostname -s)_GPFS_install.txt ]
 then
   echo "turning on GPFS on reboot on $(hostname -s)" >>${LOGFILE}
   chkconfig --level 2345 gpfs on >>${LOGFILE}
   chkconfig --list | grep gpfs >>${LOGFILE}
   echo "$(hostname -s): COMPLETE : ${MYDATE}" >>${LOGFILE}
fi
}

function re-enable_SGE {
for I in `qstat -f -u \* | grep -w $(hostname -s) | awk '{print $1}'`
 do
   echo "re-enabling ${I} on $(hostname -s)" >>${LOGFILE}
   qmod -e ${I}
   qstat -f -u \* | grep -w $(hostname -s) >>${LOGFILE}
   echo >>${LOGFILE}
   echo >>${LOGFILE}
done
}
#
#Main
#
verify_no_SGE
document_config
turn_of_GPFS_reboot
verify_gpfs_gplbin
GFPS_shutdown
install_GPFS_client
verify_GPFS_install
re-enable_SGE
