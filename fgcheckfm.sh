#!/bin/bash

##----------------------------------------------------------------------------##
## Zabbix monitor Fortigate sync with Fortimanager                            ##
##                                                                            ##
## Requirements:                                                              ##
##  * SSHPASS installed.                                                      ##
##  * SSH user and password registered in zabbix's macro.                     ##
##  * /usr/lib/zabbix/externalscripts/fgcheckfm.sh to exist                   ##
##  * Zabbix 3.0+                                                             ##
##                                                                            ##
## Created: May, 23 2020   Rafael Magalhães      Unknown changes              ##
##----------------------------------------------------------------------------##

print_usage() {
  echo ""
  echo "If you need check Fortigate sync with a Fortimanager:"
  echo "Usage: $0 [--sync] [fortigate_ip] [fortigate_snmp_community]"
  echo ""
  echo "If you need check the Fortigate license is OK:"
  echo "Usage: $0 [--lic] [fortigate_ip] [fortigate_snmp_community] [License_Type]"
  echo ""
  echo "If you need to know the time left for the Fortigate's license expire:"
  echo "Usage: $0 [--licexp] [fortigate_ip] [fortigate_snmp_community] [License_Type]"
  echo ""
  echo "If you need to check a connection with Fortigate and Fortimanager:"
  echo "Usage: $0 [--discovery] [fortigate_ip] [fortigate_snmp_community]"
  echo ""
  echo "If you need to make a license type discovery on the Fortigate:"
  echo "Usage: $0 [--conn] [fortigate_ip] [fortigate_snmp_community]"
  echo ""
  exit 3
}

check_sync() {
  fgserial=(`snmpwalk -v2c -c $community $ip $fnSysSerial | awk -F': ' '{print $2}' | tr -d '"'`)
  chksync=(`cat /var/tmp/zabbix/fortimanagersync.tmp | grep -A2 $fgserial | grep cond: | awk -F': ' '{print $5}' | awk -F';' '{print $1}'`)
  if [ "$chksync" == "OK" ]; then
    echo 1
  else
    echo 0
  fi
}

check_conn() {
  fgserial=(`snmpwalk -v2c -c $community $ip $fnSysSerial | awk -F': ' '{print $2}' | tr -d '"'`)  
  chkconn=(`cat /var/tmp/zabbix/fortimanagersync.tmp | grep -A2 $fgserial | grep conn: | awk -F': ' '{print $7}'`)
  if [ "$chkconn" == "up" ]; then
    echo 1
  else
    echo 0
  fi
}

lic_discovery() {
OldIFS=$IFS
IFS="
"

echo '{"data":['

let count=0;

fgserial=(`snmpwalk -v2c -c $community $ip $fnSysSerial | awk -F': ' '{print $2}' | tr -d '"'`)
numcontract=(`cat /var/tmp/zabbix/fortimanagerlic.tmp | grep -A1 $fgserial | grep Contract | awk -F': ' '{print $2}'`)
let "grepexdate=$numcontract+1";
lic=(`cat /var/tmp/zabbix/fortimanagerlic.tmp | grep -A $grepexdate $fgserial | grep '-' | cut -d '-' -f 1 | sed -e 's/^[ \t]*//'`)
for i in "${lic[@]}"; do
  if [ $count -gt 0 ]; then
    printf ','
    echo
  fi
  printf '{"{#LIC}":"%s"}' $i
  let count++;
done

echo
echo ']}'

IFS=$OldIFS  
}

check_lic() {
  fgserial=(`snmpwalk -v2c -c $community $ip $fnSysSerial | awk -F': ' '{print $2}' | tr -d '"'`)
  numcontract=(`cat /var/tmp/zabbix/fortimanagerlic.tmp | grep -A1 $fgserial | grep Contract | awk -F': ' '{print $2}'`)
  let "grepexdate=$numcontract+1";
  if [ "$numcontract" == "None" ]; then
    echo 255
  else
    exdate=(`cat /var/tmp/zabbix/fortimanagerlic.tmp | grep -A $grepexdate $fgserial | grep $lictype | grep '-' | cut -d '-' -f 4 | cut -d ":" -f 1`)
    dttoday=`date +%Y%m%d`
    if [ -z "$dt90exp" ]; then
      echo 99
      break
    else
      if [ $dttoday -lt $exdate ]; then
        echo 1
      else
        echo 0
      fi
    fi
  fi
}

lic_exp_date() {
  datenow=`date '+%Y-%m-%d'`
  convertdatenow=$(date --date=$datenow "+%s")
  fgserial=(`snmpwalk -v2c -c $community $ip $fnSysSerial | awk -F': ' '{print $2}' | tr -d '"'`)
  numcontract=(`cat /var/tmp/zabbix/fortimanagerlic.tmp | grep -A1 $fgserial | grep Contract | awk -F': ' '{print $2}'`)
  let "grepexdate=$numcontract+1";
  if [ "$numcontract" == "None" ]; then
    echo 255
  else
    exdate=(`cat /var/tmp/zabbix/fortimanagerlic.tmp | grep -A $grepexdate $fgserial | grep $lictype | grep '-' | cut -d '-' -f 4 | cut -d ":" -f 1`)
    convertstrtodate=$(date --date=$exdate "+%Y-%m-%d")
    convertdatetounix=$(date --date=$convertstrtodate "+%s")
    if [ $convertdatenow -gt $convertdatetounix ]; then
      echo 0
    else
      let "exptime=$convertdatetounix-$convertdatenow";
      echo $exptime
    fi
  fi
}

## GLOBAL VARIABLES
fnSysSerial="mib-2.47.1.1.1.1.11.1"

## Call functions

case "$1" in
  --help)
    print_usage
  ;;
  -h)
    print_usage
  ;;
esac

case "$1" in
  --sync)
    ip=$2
    community=$3
    check_sync
  ;;
esac

case "$1" in
  --conn)
    ip=$2
    community=$3
    check_conn
  ;;
esac

case "$1" in
  --discovery)
    ip=$2
    community=$3
    lic_discovery
  ;;
esac

case "$1" in
  --lic)
    ip=$2
    community=$3
    lictype=$4
    check_lic
  ;;
esac

case "$1" in
  --licexp)
    ip=$2
    community=$3
    lictype=$4
    lic_exp_date
  ;;
esac

exit 0