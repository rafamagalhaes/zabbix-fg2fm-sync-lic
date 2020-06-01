# Zabbix monitoring Fortigate's sync and license using Fortimanager 

Download and import the tamplate "template_fg2fm_sync_lic.xml" to your Zabbix.

Download the monitor script "fgcheckfm.sh" in externalscripts path on your Zabbix Server or Zabbix Proxy.

Download the script crtempfilesync.sh and crtempfilelic.sh in /scripts directory

Copy the crontab file content and paste in crontab on your Zabbix Proxy or Zabbix Server.

On template, configure the macro {$FG_LIC_TIME} with the expiration time's thresould.