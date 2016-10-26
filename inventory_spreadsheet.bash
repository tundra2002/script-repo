#!/bin/bash

OUTFILE=cloud_server_inventory.out
DFW_LIST=cloud_server_list_DFW.txt
LON_LIST=cloud_server_list_LON.txt
PRIVATE_KEY=/Users/joeuser/.ssh/id_rsa


collect_DFW () {
rack servers instance list | awk '{print $2,"         ",  $4}' >${DFW_LIST}
echo "-----------------------   DFW  -----------------------" >${OUTFILE}
echo "hostname ubuntu ruby python nginx tsql TDS passenger nodejs openssh openssl nginx_ssl" | awk '{ printf "%-30s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-20s %-32s %-20s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' >>${OUTFILE}
}

inventory_DFW () {
while read server_name ip_address
  do
  echo "checking ${server_name} ${ip_address}"
  ssh -q -t -i ${PUBLIC_KEY} deploy@${ip_address} 'bash -s' < ./inventory_commands.bash >>${OUTFILE}
done < ${DFW_LIST}
}

collect_LON () {
echo >>${OUTFILE}
echo >>${OUTFILE}
rack servers instance list --profile LON | awk '{print $2,"         ",  $4}' >${LON_LIST}
echo "-----------------------   LON  -----------------------" >>${OUTFILE}
echo "hostname ubuntu ruby python nginx tsql TDS passenger nodejs openssh openssl nginx_ssl" | awk '{ printf "%-30s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-20s %-32s %-20s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' >>${OUTFILE}
}

inventory_LON () {
while read server_name ip_address
  do
  echo "checking ${server_name} ${ip_address}"
  ssh -q -t -i ${PUBLIC_KEY} deploy@${ip_address} 'bash -s' < ./inventory_commands.bash >>${OUTFILE}
done < ${LON_LIST}
}


#------#
# Main #
#------#
collect_DFW
inventory_DFW
collect_LON
inventory_LON
