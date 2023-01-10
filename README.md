[![ShellCheck (master)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-master.yml/badge.svg?branch=master)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-master.yml?query=branch%3Amaster)
[![ShellCheck (devel)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-devel.yml/badge.svg?branch=devel)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-devel.yml?query=branch%3Adevel)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/ccztux/modpd?include_prereleases&label=latest%20%28pre-%29release)](https://github.com/ccztux/modpd/releases)
[![GitHub milestones](https://img.shields.io/github/milestones/open/ccztux/modpd)](https://github.com/ccztux/modpd/milestones)
[![GitHub issues](https://img.shields.io/github/issues-raw/ccztux/modpd)](https://github.com/ccztux/modpd/issues)
[![GitHub](https://img.shields.io/github/license/ccztux/modpd?color=yellowgreen)](https://github.com/ccztux/modpd/blob/master/LICENSE)



# Table of contents
* [What is modpd?](#what-is-modpd)
* [Supported monitoring engines](#supported-monitoring-engines)
* [Known Issues](#known-issues)
* [Flowchart](#flowchart)
* [Registered trademarks](#registered-trademarks)
* [Required binaries](#required-binaries)
   * [Required binaries to install modpd](#required-binaries-to-install-modpd)
   * [Required by the daemon part of modpd](#required-by-the-daemon-part-of-modpd)
   * [Optionally used binaries which depends on configured features](#optionally-used-binaries-which-depends-on-configured-features)
   * [Required for building, compiling and installing the modpd NEB module](#required-for-building-compiling-and-installing-the-modpd-neb-module)
* [Installation](#installation)
   * [Installation on the monitoring engine site executing the active checks](#installation-on-the-monitoring-engine-site-executing-the-active-checks)
      * [Download the latest sources of modpd](#download-the-latest-sources-of-modpd)
      * [Installation of the modpd NEB module part](#installation-of-the-modpd-neb-module-part)
      * [Installation of the modpd daemon part](#installation-of-the-modpd-daemon-part)
      * [Installation of the clients (of your choice)](#installation-of-the-clients-of-your-choice)
         * [send_nrdp.php](#send_nrdpphp)
         * [send_nsca](#send_nsca)
   * [Installation on the monitoring engine site accepting the passive checks](#installation-on-the-monitoring-engine-site-accepting-the-passive-checks)
      * [Installation of the server software (of your choice)](#installation-of-the-server-software-of-your-choice)
         * [NRDP](#nrdp)
         * [NSCA](#nsca)
* [Updating modpd](#updating-modpd)
   * [Make a backup](#make-a-backup)
   * [Download the latest sources of modpd](#download-the-latest-sources-of-modpd-1)
   * [Updating the modpd NEB module](#updating-the-modpd-neb-module)
   * [Updating the modpd daemon](#updating-the-modpd-daemon)
* [File overview](#file-overview)
* [Backup your modpd installation](#backup-your-modpd-installation)
* [The daemon](#the-daemon)
   * [Daemon help output](#daemon-help-output)
   * [Daemon options](#daemon-options)
   * [Default sample config](#default-sample-config)
* [Example log snippets](#example-log-snippets)
   * [modpd daemon log snippet](#modpd-daemon-log-snippet)
   * [modpd NEB module log snippet](#modpd-neb-module-log-snippet)





# What is modpd?
(**M**onitoring **O**bsessing **D**ata **P**rocessor **D**aemon)

modpd consists of a NEB module and a daemon written in bash. The NEB module collects data and writes
it to a named pipe. The daemon part reads the data from the named pipe and sends the check results
via NRDP or NSCA to another monitoring server.


# What was the motivation to develop modpd?
There were two reasons:

1. Performance
It increases the performance of an existing Nagios® 3.x.x installation greatly, because the obsessing
commands will be executed by modpd and not by the Nagios® process itself. Nagios® executes the obsessing
command after every check, where obsessing is activated and then Nagios® waits, till every obsessing
command was executed successfully or timed out.

2. Nagios® 3.x.x stops executing active checks
On some systems Nagios® 3.x.x stops randomly executing active checks when obsessing is enabled.



# Flowchart
![Alt](images/modpd.drawio.svg)



# Registered trademarks
[Nagios®](https://www.nagios.org/), Nagios Core, NRDP, NSCA, and the Nagios logo are trademarks, servicemarks, registered servicemarks or registered trademarks of Nagios Enterprises. All other trademarks, servicemarks, registered trademarks, and registered servicemarks mentioned herein may be the property of their respective owner(s). The information contained herein is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE.



# Known Issues
* [Reloading modpd is causing one invalid dataset #118](https://github.com/ccztux/modpd/issues/118)
If the daemon will be reloaded, one dataset is getting malformed and will be detected as an invalid dataset.
Nevertheless you should prefere the reload function over the restart function if you have only changed
something in the configuration, because in case of a restart more than one datasets are getting lost.





# modpd >= 3.x.x
## Supported monitoring engines
* Nagios® 3.4.x
* Naemon 1.3.x


## Requirements
### Required binaries to install modpd
- **wget** to download the latest release of modpd
- **tar** to untar the downloaded package of modpd
- **cp** to copy the files
- **chown** to change the ownership of files
- **chmod** to change the permission of files


### Required by the daemon part of modpd
- **systemcl** to control the modpd daemon
- **bash** (version >= 3)
- **whoami** to check the user who has started modpd
- **pgrep** to check if an instance of modpd is already running
- **date** for logging purposes (Only required if bash version < 4.2, else bash's printf builtin will be used.)
- **rm** to delete the named_pipe_filename
- **mkdir** to create directories
- **mkfifo** to create the named_pipe_filename
- **kill** to send signals to modpd
- **sleep** to do nothing :)
- **logrotate** to rotate modpd's logfile


### Optionally used binaries which depends on configured features
- **logger** to log to the system log
- **systemd-cat** to log to the system journal
- **timeout** to start the obsessing jobs with a timeout value
- **php** in case obsessing_interface is nrdp


### Required for building, compiling and installing the modpd NEB module
- **make** to build the modpd NEB module
- **gcc** to compile the modpd NEB module
- **install** to install the modpd NEB module
- **strip** to strip the modpd NEB binary



# modpd < 3.x.x
## Supported monitoring engines
* Nagios® 3.4.x



## Requirements
### Required binaries to install modpd
- **wget** to download the latest release of modpd
- **tar** to untar the downloaded package of modpd
- **cp** to copy the files
- **chown** to change the ownership of files
- **chmod** to change the permission of files


### Required by the daemon part of modpd
- **service** to control the modpd daemon
- **chkconfig** to enable/disable the modpd daemon at startup
- **bash** (version >= 3)
- **whoami** to check the user who has started modpd
- **pgrep** to check if an instance of modpd is already running
- **date** for logging purposes (Only required if bash version < 4.2, else bash's printf builtin will be used.)
- **rm** to delete the named_pipe_filename
- **mkdir** to create directories
- **mkfifo** to create the named_pipe_filename
- **kill** to send signals to modpd
- **sleep** to do nothing :)
- **logrotate** to rotate modpd's logfile


### Optionally used binaries which depends on configured features
- **logger** to log to the system log
- **systemd-cat** to log to the system journal
- **timeout** to start the obsessing jobs with a timeout value
- **php** in case obsessing_interface is nrdp


### Required for building, compiling and installing the modpd NEB module
- **make** to build the modpd NEB module
- **gcc** to compile the modpd NEB module
- **install** to install the modpd NEB module
- **strip** to strip the modpd NEB binary



## Installation
### Installation on the monitoring engine site executing the active checks
#### Download the latest sources of modpd
Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/ccztux/modpd/tarball" -O modpd.latest.tar.gz
tar -xvzf modpd.latest.tar.gz
cd ccztux-modpd-*
```


#### Installation of the modpd NEB module part
Build the modpd NEB module:
```bash
make
make install
```



Add the modpd NEB module with the editor of your choice to your monitoring engine main config file:

(Default Nagios® main config file: ```/usr/local/nagios/etc/nagios.cfg```)
(Default Naemon main config file: ```/etc/naemon/naemon.cfg```)
```bash
broker_module=/usr/local/nagios/include/modpd.o
```



Set the eventbroker options with the editor of your choice in your main nagios config file:

(Default Nagios® main config file: ```/usr/local/nagios/etc/nagios.cfg```)
(Default Naemon main config file: ```/etc/naemon/naemon.cfg```)
```bash
event_broker_options=-1
```


Restart your monitoring engine:
```bash
service nagios restart
```



Check if naemon is running:
```bash
service nagios status
```



Check if the modpd NEB module was loaded by your monitoring engine:
```bash
[root@lab01]:~# grep -i modpd /usr/local/nagios/var/nagios.log
[1582272717] modpd: Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved, Version: 2.3.1
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/local/nagios/include/modpd.o' initialized successfully.
```



#### Installation of the modpd daemon part
Copy the files:
```bash
cp -av ./usr/local/modpd/ /usr/local/
cp -av ./etc/* /etc/
```


Change the file ownerships:
```bash
chown -R nagios:nagios /usr/local/modpd/
chown root:root /etc/logrotate.d/modpd
chmod 644 /etc/logrotate.d/modpd
chown root:root /etc/init.d/modpd
chmod 755 /etc/init.d/modpd
chown root:root /etc/sysconfig/modpd
chmod 644 /etc/sysconfig/modpd
```


Copy the sample modpd daemon config file:
```bash
cp -av /usr/local/modpd/etc/modpd.sample.conf /usr/local/modpd/etc/modpd.conf
```


Edit the modpd daemon config to meet your requirements:
```bash
vim /usr/local/modpd/etc/modpd.conf
```


Start the modpd daemon:
```bash
service modpd start
```


Check if the modpd daemon is running:
```bash
service modpd status
tail -f /usr/local/modpd/var/log/modpd.log
```


Enable the modpd daemon at system boot:
```bash
chkconfig --add modpd
chkconfig modpd on
```


Check for which runlevels modpd is activated:
```bash
chkconfig --list modpd
```


#### Installation of the clients (of your choice)
##### send_nrdp.php

[Official NRDP Documentation by Nagios®](https://github.com/NagiosEnterprises/nrdp)

Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/NagiosEnterprises/nrdp/tarball" -O nrdp.latest.tar.gz
tar -xvzf nrdp.latest.tar.gz
cd NagiosEnterprises-nrdp-*
```


Copy the send_nrdp.php script:
```bash
cp -av ./clients/send_nrdp.php /usr/local/modpd/libexec/
```


Change the file ownership:
```bash
chown nagios:nagios /usr/local/modpd/libexec/send_nrdp.php
```


##### send_nsca

[Official NSCA Documentation by Nagios®](https://github.com/NagiosEnterprises/nsca)

Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/NagiosEnterprises/nsca/tarball" -O nsca.latest.tar.gz
tar -xvzf nsca.latest.tar.gz
cd NagiosEnterprises-nsca-*
```


Build and compile the send_nsca binary:
```bash
./configure
make send_nsca
```


Copy the files:
```bash
cp -av ./src/send_nsca /usr/local/modpd/libexec/send_nsca
cp -av ./sample-config/send_nsca.cfg /usr/local/nagios/etc/
```


Change the file ownerships:
```bash
chown nagios:nagios /usr/local/modpd/libexec/send_nsca
chown nagios:nagios /usr/local/nagios/etc/send_nsca.cfg
```


Edit the send_nsca config to meet your requirements:
```bash
vim /usr/local/nagios/etc/send_nsca.cfg
```


### Installation on the monitoring engine site accepting the passive checks
#### Installation of the server software (of your choice)
##### NRDP

[Official NRDP Documentation by Nagios®](https://github.com/NagiosEnterprises/nrdp)


##### NSCA

[Official NSCA Documentation by Nagios®](https://github.com/NagiosEnterprises/nsca)



## Updating modpd
### Make a backup
Make a backup of your existing installation as described [here](https://github.com/ccztux/modpd#backup-your-modpd-installation)


### Download the latest sources of modpd
Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/ccztux/modpd/tarball" -O modpd.latest.tar.gz
tar -xvzf modpd.latest.tar.gz
cd ccztux-modpd-*
```



### Updating the modpd NEB module
Build the modpd NEB module:
```bash
make
make install
```



Restart your monitoring engine:
```bash
service nagios restart
```



Check if your monitoring engine is running:
```bash
service nagios status
```



Check if the modpd NEB module was loaded by your monitoring engine:
```bash
[root@lab01]:~# grep -i modpd /usr/local/nagios/var/nagios.log
[1582272717] modpd: Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved, Version: 2.3.1
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/local/nagios/include/modpd.o' initialized successfully.
```



### Updating the modpd daemon
Copy the files:
```bash
cp -av ./usr/local/modpd/ /usr/local/
cp -av ./etc/* /etc/
```


Change the file ownerships:
```bash
chown -R nagios:nagios /usr/local/modpd/
chown root:root /etc/logrotate.d/modpd
chmod 644 /etc/logrotate.d/modpd
chown root:root /etc/init.d/modpd
chmod 755 /etc/init.d/modpd
chown root:root /etc/sysconfig/modpd
chmod 644 /etc/sysconfig/modpd
```


Merge possible changes between the new sample config and your productive one using the tool of your choice like vimdiff:
```bash
vimdiff ./usr/local/modpd/etc/modpd.sample.conf /usr/local/modpd/etc/modpd.conf
```


Restart the modpd daemon:
```bash
service modpd restart
```


Check if the modpd daemon is running:
```bash
service modpd status
tail -f /usr/local/modpd/var/log/modpd.log
```



## File overview
- ```/etc/init.d/modpd``` init script for the modpd daemon
- ```/etc/logrotate.d/modpd``` logrotate config file for the modpd daemon logfile
- ```/etc/sysconfig/modpd``` default configuration values for the modpd init script
- ```/usr/local/modpd/bin/modpd``` modpd daemon
- ```/usr/local/modpd/etc/modpd.conf``` configuration file for the modpd daemon
- ```/usr/local/modpd/var/log/modpd.log``` modpd daemon logfile (will be created by the daemon)
- ```/usr/local/modpd/var/log/modpd.monitoring.debug.log``` debug logfile containing raw monitoring data (will be created by the daemon)
- ```/usr/local/modpd/var/log/modpd.obsessing.debug.log``` debug logfile containing processed obsessing data (will be created by the daemon)
- ```/usr/local/modpd/var/lock/modpd.lock``` modpd daemon lockfile (will be created by the daemon)
- ```/usr/local/modpd/var/rw/modpd.cmd``` named pipe (will be created by the daemon)
- ```/usr/local/nagios/include/modpd.o``` modpd NEB module



### Daemon options
- ```service modpd status``` shows the state of the daemon
- ```service modpd start``` starts the daemon
- ```service modpd start_error_mode``` starts the daemon in error mode (bash errors are logged)
- ```service modpd stop``` stops the daemon
- ```service modpd restart``` restarts the daemon
- ```service modpd reload``` reloads the daemon (config will be re-readed)




## Backup your modpd installation
Make a backup of your existing installation:
```bash
tar -cvzf modpd.bak_$(date +%s).tar.gz /etc/init.d/modpd \
                                       /etc/logrotate.d/modpd \
                                       /etc/sysconfig/modpd \
                                       /usr/local/modpd/ \
                                       /usr/local/nagios/include/modpd.o
```



# The daemon
## Daemon help output
```
Usage: modpd OPTIONS

Author:                 Christian Zettel (ccztux)
Last modification:      2023-01-09
Version:                3.0.0

Description:            modpd (Monitoring Obsessing Data Processor Daemon)

OPTIONS:
   -h           Shows this help.
   -c           Path to config file. (Default: /usr/local/modpd/etc/modpd.conf)
   -e           Error mode. Log bash errors additionally to: /usr/local/modpd/var/log/modpd.log
                WARNING: This is not intended for use in a production environment!
   -v           Shows detailed version information.
```



## Default sample config
```bash
#!/usr/bin/env bash

#========================================================================================================
#
#  Author:				Christian Zettel (ccztux)
#						2017-05-14
#						http://linuxinside.at
#
#  Copyright:			Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved
#
#  Project website:		https://github.com/ccztux/modpd
#
#  Last Modification:	Christian Zettel (ccztux)
#						2023-01-09
#
#  Version				3.0.0
#
#  Description:			Config file for modpd (Monitoring Obsessing Data Processor Daemon)
#
#  License:				GNU GPLv2
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#========================================================================================================


#---------------------------------------------------
# In case of direct execution, write output and exit
#---------------------------------------------------

if [ "${BASH_SOURCE[0]}" == "${0}" ]
then
	printf "\\n%s is a bash config file. Dont execute it directly!\\n\\n" "${0##*/}"
	exit 1
fi



#==========================================================
#
# Modify the following parameters to meet your requirements
#
#==========================================================

#-------------------
# Obsessing settings
#-------------------

# define the obsessing interface
# (valid values: nrdp|nsca)
c_obsessing_interface="nrdp"

# define the host, where check results should be sent to
c_obsessing_host="10.0.0.31"

# define the port, where the obsessing daemon is listening on
c_obsessing_port="443"

# define the separator which should be used
c_obsessing_data_separator="\\x1e"



#----------------------------------------------------------------------
# NRDP specific settings (Needed in case c_obsessing_interface is nrdp)
#----------------------------------------------------------------------

# define the connection protocol
# (valid values: http|https)
c_nrdp_protocol="https"

# define the url path of the nrdp server
c_nrdp_url_path="/nrdp"

# define the nrdp token
c_nrdp_token="12345678"

# define the username, if nrdp basic auth is activated
c_nrdp_username="nrdpuser"

# define the password of the user you have defined in variable: c_nrdp_username with which we sould connect
c_nrdp_password="mySecret"



#----------------------------------------------------------------------
# NSCA specific settings (Needed in case c_obsessing_interface is nsca)
#----------------------------------------------------------------------

# define the path to the config file of send_nsca binary
c_nsca_config_file="/usr/local/nagios/etc/send_nsca.cfg"



#-----------------------------------------------------------------------------------------
# Proxy settings (Needed in case c_obsessing_interface is nrdp and a proxy should be used)
#-----------------------------------------------------------------------------------------

# enable proxy
c_proxy_enabled="0"

# username to authenticate on proxy server
c_proxy_username="ccztux"

# password to authenticate on proxy server
c_proxy_password="mySecret"

# proxy protocol
# (valid values: http|https)
c_proxy_protocol="https"

# proxy ip or hostname
c_proxy_ip="10.0.0.10"

# proxy port
c_proxy_port="3128"






#================================================================
#
# ONLY MODIFY THE FOLLOWING PARAMETERS, IF YOU KNOW, WHAT YOU DO!
#
#================================================================

#--------
# Logging
#--------

# enable log to file
# (valid values: 1|0)
c_log_to_file="1"

# enable log to stdout"
# (valid values: 1|0)
c_log_to_stdout="0"

# enable log to system logfile
# (valid values: 1|0)
c_log_to_syslog="0"

# enable log to system journal
# (valid values: 1|0)
c_log_to_journal="0"

# timestamp format for log messages
# (HINT: have a look at: 'man strftime')
c_log_timestamp_format="%Y-%m-%d %H:%M:%S"

# log invalid data
# (valid values: 1|0)
c_log_invalid_data="1"



#----------
# Debugging
#----------

# enable debug log of the raw data processed via c_obsessing_interface
# (valid values: 1|0)
c_debug_log_obsessing_data="0"

# enable debug log of the raw monitoring data submitted to the named pipe
# (valid values: 1|0)
c_debug_log_monitoring_data="0"

# time in seconds when the debug logfile should be truncated
c_debug_log_truncate_interval="604800"



#-------------
# Job settings
#-------------

# enable job timeout
c_job_timeout_enabled="1"

# job timeout in seconds (recommended: c_job_exec_interval * 2)
c_job_timeout="8"

# job execution interval in seconds
c_job_exec_interval="4"

# job max bulk size
c_job_max_bulk_size="250"

# log unsuccessful job commands
# (valid values: 1|0)
c_job_command_log_nok="1"

# log timed out job commands
# (valid values: 1|0)
c_job_command_log_timeout="1"

# log successful job commands
# (valid values: 1|0)
c_job_command_log_ok="0"

# log raw data in case a job was not processed successfully
# (valid values: 1|0)
c_job_command_log_nok_data="1"

# retransmit data in case a job was not processed successfully
# (valid values: 1|0)
c_job_nok_retransmit="1"



#------
# Stats
#------

# enable stats logging
c_stats_enabled="1"
```



# Example log snippets
## modpd daemon log snippet
```
2021-01-07 16:10:01 |   7084 | checkLogHandlerRequirements | modpd 3.0.0 starting... (PID=7084)
2021-01-07 16:10:01 |   7084 | checkLogHandlerRequirements | We are using the config file: '/usr/local/modpd/etc/modpd.conf'
2021-01-07 16:10:01 |   7084 |                 getExecUser | Get user which starts the daemon...
2021-01-07 16:10:01 |   7084 |                 getExecUser | modpd was started as user: 'nagios'
2021-01-07 16:10:01 |   7084 |            checkBashVersion | Checking bash version...
2021-01-07 16:10:01 |   7084 |            checkBashVersion | Bash version: '4' meets requirements
2021-01-07 16:10:01 |   7084 | checkAlreadyRunningInstance | Check if another instance of: 'modpd' is already running...
2021-01-07 16:10:01 |   7084 |                   checkLock | Check if lock file: '/usr/local/modpd/var/lock/modpd.lock' exists and if it is read and writeable...
2021-01-07 16:10:01 |   7084 |                   checkLock | Lock file doesnt exist
2021-01-07 16:10:01 |   7084 | checkAlreadyRunningInstance | No other instance of: 'modpd' is currently running (Lockfile: '/usr/local/modpd/var/lock/modpd.lock' doesnt exist and no processes are running)
2021-01-07 16:10:01 |   7084 |                     setLock | Check if daemon lock directory: '/usr/local/modpd/var/lock' exists and permissions to set lock are ok...
2021-01-07 16:10:01 |   7084 |                     setLock | Script lock directory exists and permissions are ok
2021-01-07 16:10:01 |   7084 |                     setLock | Setting lock...
2021-01-07 16:10:01 |   7084 |                     setLock | Setting lock was successful
2021-01-07 16:10:01 |   7084 |              checkNamedPipe | Check if named pipe: '/usr/local/modpd/var/rw/modpd.cmd' exists and if it is read/writeable...
2021-01-07 16:10:01 |   7084 |              checkNamedPipe | Named pipe doesnt exist
2021-01-07 16:10:01 |   7084 |             createNamedPipe | Creating named pipe...
2021-01-07 16:10:01 |   7084 |             createNamedPipe | Creating named pipe was successful
2021-01-07 16:10:01 |   7084 |             buildJobCommand | Building job command...
2021-01-07 16:10:01 |   7084 |             buildJobCommand | We build the following job command: '/usr/bin/timeout --signal=TERM 8 /usr/bin/php /usr/local/modpd/libexec/send_nrdp.php --usestdin --delim="" --token="[HIDDEN FOR SECURITY]" --url=https://nrdpuser:[HIDDEN FOR SECURITY]@10.0.0.74:443/nrdp'
2021-01-07 16:10:01 |   7084 |                       _main | Ready to handle jobs...
2021-01-07 16:11:01 |   7084 |               dataProcessor | WARNING: No monitoring data received within the last 60 seconds! Is the monitoring system running?
2021-01-07 16:15:03 |   7084 |                    logStats | -------------- Stats for the last 302 seconds --------------
2021-01-07 16:15:03 |   7084 |                    logStats | Process info:
2021-01-07 16:15:03 |   7084 |                    logStats | modpd is running: 0d 0h 5m 2s
2021-01-07 16:15:03 |   7084 |                    logStats |
2021-01-07 16:15:03 |   7084 |                    logStats | Processed jobs:
2021-01-07 16:15:03 |   7084 |                    logStats | Total processed jobs: '50'
2021-01-07 16:15:03 |   7084 |                    logStats | Successful processed jobs: '50'
2021-01-07 16:15:03 |   7084 |                    logStats | Unsuccessful processed jobs: '0'
2021-01-07 16:15:03 |   7084 |                    logStats | Timed out jobs: '0'
2021-01-07 16:15:03 |   7084 |                    logStats |
2021-01-07 16:15:03 |   7084 |                    logStats | Retransmission jobs:
2021-01-07 16:15:03 |   7084 |                    logStats | Total retransmission jobs: '0'
2021-01-07 16:15:03 |   7084 |                    logStats | Successful retransmission jobs: '0'
2021-01-07 16:15:03 |   7084 |                    logStats | Unsuccessful retransmission jobs: '0'
2021-01-07 16:15:03 |   7084 |                    logStats | Timed out retransmission jobs: '0'
2021-01-07 16:15:03 |   7084 |                    logStats |
2021-01-07 16:15:03 |   7084 |                    logStats | Handled checks:
2021-01-07 16:15:03 |   7084 |                    logStats | Host checks: '7106'
2021-01-07 16:15:03 |   7084 |                    logStats | Service checks: '4202'
2021-01-07 16:15:03 |   7084 |                    logStats | Invalid datasets received: '0'
2021-01-07 16:15:03 |   7084 |                    logStats |
2021-01-07 16:15:03 |   7084 |             debugLogHandler | WARNING: Debug log enabled! This is not intended for use in a production environment!
2021-01-07 16:15:31 |   7084 |               signalHandler | Caught: 'SIGTERM', preparing for shutdown...
2021-01-07 16:15:31 |   7084 |                    logStats | -------------- Stats for the last 28 seconds --------------
2021-01-07 16:15:31 |   7084 |                    logStats | Process info:
2021-01-07 16:15:31 |   7084 |                    logStats | modpd is running: 0d 0h 5m 30s
2021-01-07 16:15:31 |   7084 |                    logStats |
2021-01-07 16:15:31 |   7084 |                    logStats | Processed jobs:
2021-01-07 16:15:31 |   7084 |                    logStats | Total processed jobs: '7'
2021-01-07 16:15:31 |   7084 |                    logStats | Successful processed jobs: '7'
2021-01-07 16:15:31 |   7084 |                    logStats | Unsuccessful processed jobs: '0'
2021-01-07 16:15:31 |   7084 |                    logStats | Timed out jobs: '0'
2021-01-07 16:15:31 |   7084 |                    logStats |
2021-01-07 16:15:31 |   7084 |                    logStats | Retransmission jobs:
2021-01-07 16:15:31 |   7084 |                    logStats | Total retransmission jobs: '0'
2021-01-07 16:15:31 |   7084 |                    logStats | Successful retransmission jobs: '0'
2021-01-07 16:15:31 |   7084 |                    logStats | Unsuccessful retransmission jobs: '0'
2021-01-07 16:15:31 |   7084 |                    logStats | Timed out retransmission jobs: '0'
2021-01-07 16:15:31 |   7084 |                    logStats |
2021-01-07 16:15:31 |   7084 |                    logStats | Handled checks:
2021-01-07 16:15:31 |   7084 |                    logStats | Host checks: '719'
2021-01-07 16:15:31 |   7084 |                    logStats | Service checks: '750'
2021-01-07 16:15:31 |   7084 |                    logStats | Invalid datasets received: '0'
2021-01-07 16:15:31 |   7084 |                    logStats |
2021-01-07 16:15:31 |   7084 |               signalHandler | Caught: 'EXIT', shutting down...
2021-01-07 16:15:31 |   7084 |              checkNamedPipe | Check if named pipe: '/usr/local/modpd/var/rw/modpd.cmd' exists and if it is read/writeable...
2021-01-07 16:15:31 |   7084 |              checkNamedPipe | Named pipe exists and it is read/writeable
2021-01-07 16:15:31 |   7084 |             removeNamedPipe | Remove named pipe...
2021-01-07 16:15:31 |   7084 |             removeNamedPipe | Removing named pipe was successful
2021-01-07 16:15:31 |   7084 |                   checkLock | Check if lock file: '/usr/local/modpd/var/lock/modpd.lock' exists and if it is read and writeable...
2021-01-07 16:15:31 |   7084 |                   checkLock | Lock file exists and it is read/writeable
2021-01-07 16:15:31 |   7084 |                  removeLock | Removing lock...
2021-01-07 16:15:31 |   7084 |                  removeLock | Removing lock was successful
2021-01-07 16:15:31 |   7084 |               signalHandler | Exitcode: '143'
2021-01-07 16:15:31 |   7084 |               signalHandler | modpd was running: 0d 0h 5m 30s
2021-01-07 16:15:31 |   7084 |               signalHandler | Bye, bye...
```


## modpd NEB module log snippet
```
[1607849563] modpd: Copyright © 2017-NOW Christian Zettel (ccztux), all rights reserved, Version: 3.0.0
[1607849563] modpd: Starting...
[1607849563] Event broker module '/usr/local/nagios/include/modpd.o' initialized successfully.
[1607849863] modpd: The modpd NEB module is running 0d 0h 5m 0s
[1607849863] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 9941 (OK: 9941/NOK: 0), Services: 7127 (OK: 7077/NOK: 50) ***
[1607850163] modpd: The modpd NEB module is running 0d 0h 10m 0s
[1607850163] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 10276 (OK: 10276/NOK: 0), Services: 7553 (OK: 7553/NOK: 0) ***
[1607850463] modpd: The modpd NEB module is running 0d 0h 15m 0s
[1607850463] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 9684 (OK: 9684/NOK: 0), Services: 7452 (OK: 7452/NOK: 0) ***
[1607850763] modpd: The modpd NEB module is running 0d 0h 20m 0s
```
