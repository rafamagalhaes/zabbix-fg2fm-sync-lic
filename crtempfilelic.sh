#!/bin/bash

##----------------------------------------------------------------------------##
## Zabbix create temporary file to monitor Fortigate sync with Fortimanager   ##
##                                                                            ##
## Requirements:                                                              ##
##  * SSHPASS installed.                                                      ##
##                                                                            ##
## Created: May, 31 2020   Rafael Magalhães      Unknown changes              ##
##----------------------------------------------------------------------------##

sshpass -p $2 ssh -q -o StrictHostKeyChecking=no $1@177.154.136.140 diagnose fmupdate dbcontract fgd > /var/tmp/zabbix/fortimanagerlic.tmp