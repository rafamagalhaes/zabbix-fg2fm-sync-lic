# Zabbix monitoring Fortigate's sync and license using Fortimanager 

Download and import the tamplate "template_fg2fm_sync_lic.xml" to your Zabbix.

Download the monitor script "fgcheckfm.sh" in externalscripts path on your Zabbix Server or Zabbix Proxy.

On template, configure the macros {$user} and {$pass} with your Fortimanager's username and password and {$FG_LIC_TIME} with the expiration time's thresould.
