[![ShellCheck (master)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-master.yml/badge.svg?branch=master)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-master.yml?query=branch%3Amaster)
[![ShellCheck (devel)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-devel.yml/badge.svg?branch=devel)](https://github.com/ccztux/modpd/actions/workflows/shellcheck-devel.yml?query=branch%3Adevel)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/ccztux/modpd?include_prereleases&label=latest%20%28pre-%29release)](https://github.com/ccztux/modpd/releases)
[![GitHub milestones](https://img.shields.io/github/milestones/open/ccztux/modpd)](https://github.com/ccztux/modpd/milestones)
[![GitHub issues](https://img.shields.io/github/issues-raw/ccztux/modpd)](https://github.com/ccztux/modpd/issues)
[![GitHub](https://img.shields.io/github/license/ccztux/modpd?color=yellowgreen)](https://github.com/ccztux/modpd/blob/master/LICENSE)



# Table of Contents
* [What is modpd?](#what-is-modpd)
* [What was the motivation to develop modpd?](#what-was-the-motivation-to-develop-modpd)
* [Flowchart](#flowchart)
* [Registered trademarks](#registered-trademarks)
* [Known Issues](#known-issues)
* [Supported monitoring engines](#supported-monitoring-engines)
   * [modpd &gt;= 3.1.x](#modpd--31x)
   * [modpd == 3.0.x](#modpd--30x)
   * [modpd &lt; 3.0.0](#modpd--300)
* [Requirements](#requirements)
   * [Required for building, compiling and installing the NEB modules and modpd](#required-for-building-compiling-and-installing-the-neb-modules-and-modpd)
   * [Required binaries for the installation of NRDP](#required-binaries-for-the-installation-of-nrdp)
   * [Required binaries for the installation of NSCA](#required-binaries-for-the-installation-of-nsca)
   * [Required by the daemon part of modpd](#required-by-the-daemon-part-of-modpd)
   * [Optionally used binaries which depends on configured features](#optionally-used-binaries-which-depends-on-configured-features)
* [Installation on the monitoring site which executes the active checks](#installation-on-the-monitoring-site-which-executes-the-active-checks)
   * [Download the latest sources of modpd](#download-the-latest-sources-of-modpd)
   * [Create the required linux user and set a password](#create-the-required-linux-user-and-set-a-password)
   * [Add the user nagios to the modpd group](#add-the-user-nagios-to-the-modpd-group)
   * [Add the user naemon to the modpd group](#add-the-user-naemon-to-the-modpd-group)
   * [Build the modpd NEB modules and install them and the modpd daemon](#build-the-modpd-neb-modules-and-install-them-and-the-modpd-daemon)
   * [Edit the modpd daemon config to meet your requirements](#edit-the-modpd-daemon-config-to-meet-your-requirements)
   * [Start the modpd daemon](#start-the-modpd-daemon)
   * [Enable the modpd daemon at system boot](#enable-the-modpd-daemon-at-system-boot)
   * [Add the NEB module to your monitoring engine](#add-the-neb-module-to-your-monitoring-engine)
      * [Add the NEB module to Nagios®](#add-the-neb-module-to-nagios)
      * [Add the NEB module to Naemon](#add-the-neb-module-to-naemon)
   * [Installation of the clients (of your choice)](#installation-of-the-clients-of-your-choice)
      * [send_nrdp.php](#send_nrdpphp)
      * [send_nsca](#send_nsca)
* [Installation on the monitoring site which accepts the passive checks](#installation-on-the-monitoring-site-which-accepts-the-passive-checks)
   * [Installation of the server software (of your choice)](#installation-of-the-server-software-of-your-choice)
      * [NRDP](#nrdp)
      * [NSCA](#nsca)
* [Updating modpd](#updating-modpd)
   * [Make a backup](#make-a-backup)
   * [Download the latest sources of modpd](#download-the-latest-sources-of-modpd-1)
   * [Build the modpd NEB modules and install them and the modpd daemon](#build-the-modpd-neb-modules-and-install-them-and-the-modpd-daemon-1)
   * [Restart your monitoring engine](#restart-your-monitoring-engine)
      * [Nagios](#nagios)
      * [Naemon](#naemon)
   * [Check and merge eventual new configuration variables](#check-and-merge-eventual-new-configuration-variables)
   * [Restart the modpd daemon](#restart-the-modpd-daemon)
* [The daemon](#the-daemon)
   * [Daemon help output](#daemon-help-output)
   * [File overview](#file-overview)
   * [Daemon control options](#daemon-control-options)
   * [Default sample config](#default-sample-config)
   * [Example log snippets](#example-log-snippets)
      * [modpd daemon log snippet](#modpd-daemon-log-snippet)
      * [modpd NEB module log snippet](#modpd-neb-module-log-snippet)
* [Backup your modpd installation](#backup-your-modpd-installation)
* [Upgrading modpd from 2.x.x to 3.x.x](#upgrading-modpd-from-2xx-to-3xx)
   * [Backup your modpd installation](#backup-your-modpd-installation-1)
   * [Remove the old installation](#remove-the-old-installation)
      * [Stop the modpd daemon](#stop-the-modpd-daemon)
      * [Remove the files](#remove-the-files)
      * [Remove the NEB module from Nagios®](#remove-the-neb-module-from-nagios)
      * [Restart Nagios®](#restart-nagios)
   * [Install modpd 3.x.x](#install-modpd-3xx)




# What is modpd?
(**M**onitoring **O**bsessing **D**ata **P**rocessor **D**aemon)

modpd consists of a NEB module and a daemon written in bash. The NEB module collects data and writes
it to a named pipe. The daemon part reads the data from the named pipe and sends the check results
via NRDP, NSCA or Icinga2 API to another monitoring server.


# What was the motivation to develop modpd?
There were two reasons:

1. Performance \
It increases the performance of an existing Nagios® 3.x.x installation greatly, because the obsessing
commands will be executed by modpd and not by the Nagios® process itself. Nagios® executes the obsessing
command after every check, where obsessing is activated and then Nagios® waits, till every obsessing
command was executed successfully or timed out.

2. Nagios® 3.x.x stops executing active checks \
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


# Supported monitoring engines
## modpd >= 3.1.x
* Nagios® 3.4.x
* Naemon 1.3.x
* Icinga2 via Icinga2 API (Only on the passive checks site!)



## modpd == 3.0.x
* Nagios® 3.4.x
* Naemon 1.3.x


## modpd < 3.0.0
* Nagios® 3.4.x



# Requirements
## Required for building, compiling and installing the NEB modules and modpd
- **wget** to download the latest release of modpd
- **tar** to untar the downloaded package of modpd
- **make** to build the modpd NEB modules
- **gcc** to compile the modpd NEB modules
- **install** to install the modpd NEB modules
- **strip** to strip the modpd NEB binaries
- **useradd** to add the modpd linux user
- **passwd** to set a password for the user modpd
- **usermod** to add users to the modpd group


## Required binaries for the installation of NRDP
- **wget** to download the package
- **tar** to untar the downloaded package
- **cp** to copy files
- **chown** to change the ownership of files
- **php** to run the application


## Required binaries for the installation of NSCA
- **wget** to download the package
- **tar** to untar the downloaded package
- **make** to build the modpd NEB modules
- **gcc** to compile the modpd NEB modules
- **cp** to copy files
- **chown** to change the ownership of files


## Required by the daemon part of modpd
- **systemctl** to control the modpd daemon
- **bash** (version >= 3)
- **whoami** to check the user who has started modpd
- **pgrep** to check if an instance of modpd is already running
- **grep** for common purposes
- **date** for logging purposes (Only required if bash version < 4.2, else bash's printf builtin will be used.)
- **rm** to delete the named_pipe_filename
- **mkdir** to create directories
- **mkfifo** to create the named_pipe_filename
- **kill** to send signals to modpd
- **sleep** to do nothing :)
- **logrotate** to rotate modpd's logfile


## Optionally used binaries which depends on configured features
- **logger** to log to the system log
- **systemd-cat** to log to the system journal
- **timeout** to start the obsessing jobs with a timeout value
- **php** in case obsessing_interface is nrdp




# Installation on the monitoring site which executes the active checks
## Download the latest sources of modpd
Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/ccztux/modpd/tarball" -O modpd.latest.tar.gz
tar -xvzf modpd.latest.tar.gz
cd ccztux-modpd-*
```


## Create the required linux user and set a password
```bash
useradd -s /sbin/nologin modpd
passwd modpd
```


## Add the user nagios to the modpd group
**Do this only, if you use Nagios®!**
```bash
usermod -aG modpd nagios
```


## Add the user naemon to the modpd group
**Do this only, if you use Naemon!**
```bash
usermod -aG modpd naemon
```


## Build the modpd NEB modules and install them and the modpd daemon
```bash
make
make install
```


## Edit the modpd daemon config to meet your requirements
```bash
vim /etc/modpd/modpd.conf
```


## Start the modpd daemon
```bash
systemctl start modpd
```


Check if the modpd daemon is running
```bash
systemctl status modpd
tail -f /var/log/modpd/modpd.log
```


## Enable the modpd daemon at system boot
```bash
systemctl enable modpd
```

Check if modpd is activated at system boot
```bash
systemctl status modpd
```


## Add the NEB module to your monitoring engine
### Add the NEB module to Nagios®
**Do this only, if you use Nagios®!**

Add the modpd NEB module with the editor of your choice to your Nagios® main config file:

(Default Nagios® main config file: `/usr/local/nagios/etc/nagios.cfg`)
```bash
broker_module=/usr/lib64/modpd/modpd_nagios3.o
```


Set the eventbroker options with the editor of your choice in your main nagios config file:

(Default Nagios® main config file: `/usr/local/nagios/etc/nagios.cfg`)
```bash
event_broker_options=-1
```

Restart nagios:
```bash
systemctl restart nagios
```

Check if nagios is running:
```bash
systemctl status nagios
```


Check if the modpd NEB module was loaded by nagios:
```bash
[root@lab01]:~# grep -i modpd /usr/local/nagios/var/nagios.log
[1582272717] modpd: Copyright © 2017-NOW Christian Zettel (ccztux), all rights reserved, Version: 3.1.0
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/lib64/modpd/modpd_nagios3.o' initialized successfully.
```



### Add the NEB module to Naemon
**Do this only, if you use Naemon!**

Add the modpd NEB module with the editor of your choice to your Naemon main config file:

(Default Naemon main config file: `/etc/naemon/naemon.cfg`)
```bash
broker_module=/usr/lib64/modpd/modpd_naemon.o
```


Set the eventbroker options with the editor of your choice in your main naemon config file:

(Default Naemon main config file: `/etc/naemon/naemon.cfg`)
```bash
event_broker_options=-1
```

Restart naemon:
```bash
systemctl restart naemon
```

Check if naemon is running:
```bash
systemctl status naemon
```


Check if the modpd NEB module was loaded by naemon:
```bash
[root@lab01]:~# grep -i modpd /var/log/naemon/naemon.log
[1582272717] modpd: Copyright © 2017-NOW Christian Zettel (ccztux), all rights reserved, Version: 3.1.0
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/lib64/modpd/modpd_naemon.o' initialized successfully.
```




## Installation of the clients (of your choice)
### send_nrdp.php

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
cp -av ./clients/send_nrdp.php /usr/libexec/modpd/
```


Change the file ownership:
```bash
chown root:root /usr/libexec/modpd/send_nrdp.php
```


### send_nsca

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
cp -av ./src/send_nsca /usr/libexec/modpd/send_nsca
cp -av ./sample-config/send_nsca.cfg /etc/modpd/
```


Change the file ownerships:
```bash
chown root:root /usr/libexec/modpd/send_nsca
chown modpd:modpd /etc/modpd/send_nsca.cfg
```


Edit the send_nsca config to meet your requirements:
```bash
vim /etc/modpd/send_nsca.cfg
```



# Installation on the monitoring site which accepts the passive checks
## Installation of the server software (of your choice)
### NRDP

[Official NRDP Documentation by Nagios®](https://github.com/NagiosEnterprises/nrdp)


### NSCA

[Official NSCA Documentation by Nagios®](https://github.com/NagiosEnterprises/nsca)



# Updating modpd
## Make a backup
Make a backup of your existing installation as described [here](#backup-your-modpd-installation)


## Download the latest sources of modpd
Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/ccztux/modpd/tarball" -O modpd.latest.tar.gz
tar -xvzf modpd.latest.tar.gz
cd ccztux-modpd-*
```



## Build the modpd NEB modules and install them and the modpd daemon
```bash
make
make install
```



## Restart your monitoring engine
### Nagios
Restart nagios:
```bash
systemctl restart nagios
```

Check if nagios is running:
```bash
systemctl status nagios
```


Check if the modpd NEB module was loaded by nagios:
```bash
[root@lab01]:~# grep -i modpd /usr/local/nagios/var/nagios.log
[1582272717] modpd: Copyright © 2017-NOW Christian Zettel (ccztux), all rights reserved, Version: 3.1.0
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/lib64/modpd/modpd_nagios3.o' initialized successfully.
```



### Naemon
Restart naemon:
```bash
systemctl restart naemon
```


Check if naemon is running:
```bash
systemctl status naemon
```


Check if the modpd NEB module was loaded by naemon:
```bash
[root@lab01]:~# grep -i modpd /var/log/naemon/naemon.log
[1582272717] modpd: Copyright © 2017-NOW Christian Zettel (ccztux), all rights reserved, Version: 3.1.0
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/lib64/modpd/modpd_naemon.o' initialized successfully.
```



## Check and merge eventual new configuration variables
Merge possible changes between the new sample config and your productive one using the tool of your choice like vimdiff:
```bash
vimdiff /etc/modpd/modpd.sample.conf /etc/modpd/modpd.conf
```


## Restart the modpd daemon
```bash
systemctl daemon-reload
systemctl restart modpd
```


Check if the modpd daemon is running:
```bash
systemctl status modpd
tail -f /var/log/modpd/modpd.log
```




# The daemon
## Daemon help output
```
Usage: modpd OPTIONS

Author:                 Christian Zettel (ccztux)
#						2023-07-10
Version:                3.1.0

Description:            modpd (Monitoring Obsessing Data Processor Daemon)

OPTIONS:
   -h           Shows this help.
   -c           Path to config file. (Default: /etc/modpd/modpd.conf)
   -e           Error mode. Log bash errors additionally to: /var/log/modpd/modpd.log
                WARNING: This is not intended for use in a production environment!
   -v           Shows detailed version information.
```



## File overview
- `/etc/logrotate.d/modpd` logrotate config file for the modpd daemon logfile
- `/etc/sysconfig/modpd` default configuration values for the system unit file
- `/usr/bin/modpd` modpd daemon
- `/etc/modpd/modpd.conf` configuration file for the modpd daemon
- `/etc/modpd/modpd.sample.conf` sample configuration file for the modpd daemon
- `/usr/lib/systemd/system/modpd.service` systemd unit file for modpd
- `/usr/lib64/modpd/modpd_nagios3.o` modpd NEB module for Nagios® 3.x.x
- `/usr/lib64/modpd/modpd_naemon.o` modpd NEB module for Naemon 1.3.x
- `/var/lib/modpd/lock/modpd.lock` modpd daemon lockfile (will be created by the daemon)
- `/var/lib/modpd/rw/modpd.cmd` named pipe (will be created by the daemon)
- `/var/log/modpd/modpd.log` modpd daemon logfile (will be created by the daemon)
- `/var/log/modpd/modpd.monitoring.debug.log` debug logfile containing raw monitoring data (will be created by the daemon)
- `/var/log/modpd/modpd.obsessing.debug.log` debug logfile containing processed obsessing data (will be created by the daemon)



## Daemon control options
- `systemctl status modpd` shows the state of the daemon
- `systemctl start modpd` starts the daemon
- `systemctl stop modpd` stops the daemon
- `systemctl restart modpd` restarts the daemon
- `systemctl reload modpd` reloads the daemon (config will be re-readed)



## Default sample config
```bash
#!/usr/bin/env bash

#========================================================================================================
#
#  Author:				Christian Zettel (ccztux)
#						2017-05-14
#						http://linuxinside.at
#
#  Copyright:			Copyright © 2017-NOW Christian Zettel (ccztux), all rights reserved
#
#  Project website:		https://github.com/ccztux/modpd
#
#  Last Modification:	Christian Zettel (ccztux)
#						2023-07-10
#
#  Version				3.1.0
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
# (valid values: nrdp|nsca|icinga)
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



#--------------------------------------------------------------------------------
# Icinga2 API specific settings (Needed in case c_obsessing_interface is icinga2)
#--------------------------------------------------------------------------------

# define the connection protocol
# (valid values: http|https)
c_icinga_protocol="https"

# define the username to connect as with Icinga2 API
c_icinga_username="icingauser"

# define the password of the user you have defined in variable: c_icinga_username with which we sould connect
c_icinga_password="mySecret"



#----------------------------------------------------------------------
# NSCA specific settings (Needed in case c_obsessing_interface is nsca)
#----------------------------------------------------------------------

# define the path to the config file of send_nsca binary
c_nsca_config_file="/etc/modpd/send_nsca.cfg"



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



## Example log snippets
### modpd daemon log snippet
```
2021-01-07 16:10:01 |   7084 | checkLogHandlerRequirements | modpd 3.1.0 starting... (PID=7084)
2021-01-07 16:10:01 |   7084 | checkLogHandlerRequirements | We are using the config file: '/etc/modpd/modpd.conf'
2021-01-07 16:10:01 |   7084 |                 getExecUser | Get user which starts the daemon...
2021-01-07 16:10:01 |   7084 |                 getExecUser | modpd was started as user: 'nagios'
2021-01-07 16:10:01 |   7084 |            checkBashVersion | Checking bash version...
2021-01-07 16:10:01 |   7084 |            checkBashVersion | Bash version: '4' meets requirements
2021-01-07 16:10:01 |   7084 | checkAlreadyRunningInstance | Check if another instance of: 'modpd' is already running...
2021-01-07 16:10:01 |   7084 |                   checkLock | Check if lock file: '/var/lib/modpd/lock/modpd.lock' exists and if it is read and writeable...
2021-01-07 16:10:01 |   7084 |                   checkLock | Lock file doesnt exist
2021-01-07 16:10:01 |   7084 | checkAlreadyRunningInstance | No other instance of: 'modpd' is currently running (Lockfile: '/var/lib/modpd/lock/modpd.lock' doesnt exist and no processes are running)
2021-01-07 16:10:01 |   7084 |                     setLock | Check if daemon lock directory: '/var/lib/modpd/lock' exists and permissions to set lock are ok...
2021-01-07 16:10:01 |   7084 |                     setLock | Script lock directory exists and permissions are ok
2021-01-07 16:10:01 |   7084 |                     setLock | Setting lock...
2021-01-07 16:10:01 |   7084 |                     setLock | Setting lock was successful
2021-01-07 16:10:01 |   7084 |              checkNamedPipe | Check if named pipe: '/var/lib/modpd/rw/modpd.cmd' exists and if it is read/writeable...
2021-01-07 16:10:01 |   7084 |              checkNamedPipe | Named pipe doesnt exist
2021-01-07 16:10:01 |   7084 |             createNamedPipe | Creating named pipe...
2021-01-07 16:10:01 |   7084 |             createNamedPipe | Creating named pipe was successful
2021-01-07 16:10:01 |   7084 |             buildJobCommand | Building job command...
2021-01-07 16:10:01 |   7084 |             buildJobCommand | We build the following job command: '/usr/bin/timeout --signal=TERM 8 /usr/bin/php /usr/libexec/modpd/send_nrdp.php --usestdin --delim="" --token="[HIDDEN FOR SECURITY]" --url=https://nrdpuser:[HIDDEN FOR SECURITY]@10.0.0.74:443/nrdp'
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
2021-01-07 16:15:31 |   7084 |              checkNamedPipe | Check if named pipe: '/var/lib/modpd/rw/modpd.cmd' exists and if it is read/writeable...
2021-01-07 16:15:31 |   7084 |              checkNamedPipe | Named pipe exists and it is read/writeable
2021-01-07 16:15:31 |   7084 |             removeNamedPipe | Remove named pipe...
2021-01-07 16:15:31 |   7084 |             removeNamedPipe | Removing named pipe was successful
2021-01-07 16:15:31 |   7084 |                   checkLock | Check if lock file: '/var/lib/modpd/lock/modpd.lock' exists and if it is read and writeable...
2021-01-07 16:15:31 |   7084 |                   checkLock | Lock file exists and it is read/writeable
2021-01-07 16:15:31 |   7084 |                  removeLock | Removing lock...
2021-01-07 16:15:31 |   7084 |                  removeLock | Removing lock was successful
2021-01-07 16:15:31 |   7084 |               signalHandler | Exitcode: '143'
2021-01-07 16:15:31 |   7084 |               signalHandler | modpd was running: 0d 0h 5m 30s
2021-01-07 16:15:31 |   7084 |               signalHandler | Bye, bye...
```


### modpd NEB module log snippet
```
[1607849563] modpd: Copyright © 2017-NOW Christian Zettel (ccztux), all rights reserved, Version: 3.1.0
[1607849563] modpd: Starting...
[1607849563] Event broker module '/usr/lib64/modpd/modpd_naemon.o' initialized successfully.
[1607849863] modpd: The modpd NEB module is running 0d 0h 5m 0s
[1607849863] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 9941 (OK: 9941/NOK: 0), Services: 7127 (OK: 7077/NOK: 50) ***
[1607850163] modpd: The modpd NEB module is running 0d 0h 10m 0s
[1607850163] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 10276 (OK: 10276/NOK: 0), Services: 7553 (OK: 7553/NOK: 0) ***
[1607850463] modpd: The modpd NEB module is running 0d 0h 15m 0s
[1607850463] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 9684 (OK: 9684/NOK: 0), Services: 7452 (OK: 7452/NOK: 0) ***
[1607850763] modpd: The modpd NEB module is running 0d 0h 20m 0s
```



# Backup your modpd installation
Make a backup of your existing installation:
```bash
tar -cvzf modpd.bak_$(date +%s).tar.gz /etc/logrotate.d/modpd \
                                       /etc/modpd/ \
                                       /etc/sysconfig/modpd \
                                       /usr/bin/modpd \
                                       /usr/lib/systemd/system/modpd.service \
                                       /usr/lib64/modpd/ \
                                       /var/lib/modpd/ \
                                       /var/log/modpd/
```



# Upgrading modpd from 2.x.x to 3.x.x
## Backup your modpd installation
Make a backup of your existing installation:
```bash
tar -cvzf modpd.bak_$(date +%s).tar.gz /etc/init.d/modpd \
                                       /etc/logrotate.d/modpd \
                                       /etc/sysconfig/modpd \
                                       /usr/local/modpd/ \
                                       /usr/local/nagios/include/modpd.o
```


## Remove the old installation
### Stop the modpd daemon
```bash
service modpd stop
```

### Remove the files
```bash
chkconfig --del modpd
rm /etc/init.d/modpd
rm /etc/logrotate.d/modpd
rm /etc/sysconfig/modpd
rm -rf /usr/local/modpd/
rm /usr/local/nagios/include/modpd.o
```

### Remove the NEB module from Nagios®
Remove the modpd NEB module with the editor of your choice to your Nagios® main config file:

(Default Nagios® main config file: /usr/local/nagios/etc/nagios.cfg)
```bash
broker_module=/usr/local/nagios/include/modpd.o
```

### Restart Nagios®
```bash
service nagios restart
```

## Install modpd 3.x.x
Use the [regular install guide](#installation-on-the-monitoring-site-which-executes-the-active-checks)
and merge possible changes between the new config and the old one from your backup using the tool of
your choice like vimdiff.
