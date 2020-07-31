#!/bin/bash

##----------------------------------------------------------------------------##
## Zabbix create temporary file to monitor Fortigate sync with Fortimanager   ##
##                                                                            ##
## Requirements:                                                              ##
##  * SSHPASS installed.                                                      ##
##                                                                            ##
## Created: May, 31 2020   Rafael Magalhães      Unknown changes              ##
##----------------------------------------------------------------------------##

sshpass -p $2 ssh -q -o StrictHostKeyChecking=no $1@$3 diagnose fmupdate dbcontract fgd > /var/tmp/zabbix/fortimanagerlic.tmp
