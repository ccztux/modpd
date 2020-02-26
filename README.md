[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/master?label=shellcheck%28master%29)](https://travis-ci.org/ccztux/modpd)
[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/devel?label=shellcheck%28devel%29)](https://travis-ci.org/ccztux/modpd)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ccztux/modpd?label=latest%20release)](https://github.com/ccztux/modpd/releases/latest)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/ccztux/modpd?include_prereleases&label=latest%20pre-release)](https://github.com/ccztux/modpd/releases/tag/2.1.3)
[![GitHub](https://img.shields.io/github/license/ccztux/modpd?color=yellowgreen)](https://github.com/ccztux/modpd/blob/master/LICENSE)



# modpd
(**M**onitoring **O**bsessing **D**ata **P**rocessor **D**aemon)

modpd consists of a NEB module and a daemon written in bash. The NEB module collects data and writes
it to a named pipe. The daemon part reads the data from the named pipe and sends the check results
via NRDP or NSCA to another Nagios® server. It increases the performance of an existing Nagios® 3.x.x
installation greatly, because the obsessing commands will be executed by modpd and not by the Nagios®
process itself. Nagios® executes the obsessing command after every check, where obsessing is activated
and then Nagios® waits, till every obsessing command was executed successfully or timed out.



# Flowchart
![Alt](images/modpd.png)



# Registered trademarks
[Nagios®](https://www.nagios.org/) is a registered trademark


# Required binaries
## Required binaries to install modpd
- **wget** to download the latest release of modpd
- **tar** to untar the downloaded package of modpd
- **cp** to copy the files


## Required by the daemon part of modpd
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


## Optionally used binaries which depends on configured features
- **logger** to log to the system log
- **systemd-cat** to log to the system journal
- **timeout** to start the obsessing jobs with a timeout value
- **php** in case obsessing_interface is nrdp


## Required for building, compiling and installing the modpd NEB module
- **make** to build the modpd NEB module
- **gcc** to compile the modpd NEB module
- **install** to install the modpd NEB module
- **strip** to strip the modpd NEB binary



# Installation
## Installation on the Nagios® site with active checks
### Download the latest sources of modpd
Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/ccztux/modpd/tarball" -O modpd.latest.tar.gz
tar -xvzf modpd.latest.tar.gz
cd ccztux-modpd-*
```


### Installation of the modpd NEB module part
Build the modpd NEB module:
```bash
make
make install
```



Add the modpd NEB module with the editor of your choice to your main Nagios® config file

(Default Nagios® main config file: ```/usr/local/nagios/etc/nagios.cfg```):

**Skip this step in case of an update!**
```bash
broker_module=/usr/local/nagios/include/modpd.o
```



Set the eventbroker options with the editor of your choice in your main nagios config file

(Default Nagios® main config file: ```/usr/local/nagios/etc/nagios.cfg```):

**Skip this step in case of an update!**
```bash
event_broker_options=-1
```


Restart nagios:
```bash
service nagios restart
```



Check if nagios is running:
```bash
service nagios status
```



Check if the modpd NEB module was loaded by Nagios®:
```bash
[root@lab01]:~# grep -i modpd /usr/local/nagios/var/nagios.log
[1582272717] modpd: Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved, Version: 2.1.2
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/local/nagios/include/modpd.o' initialized successfully.
```



### Installation of the modpd daemon part
Copy the files:
```bash
cp -av ./usr/local/modpd/ /usr/local/
cp -av ./etc/ /etc/
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


### Installation of the clients (of your choice)
#### send_nrdp.php

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


#### send_nsca

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


## Installation on the Nagios® site with passive checks
### Installation of the server software (of your choice)
#### NRDP

[Official NRDP Documentation by Nagios®](https://github.com/NagiosEnterprises/nrdp)


#### NSCA

[Official NSCA Documentation by Nagios®](https://github.com/NagiosEnterprises/nsca)


# Upgrading modpd
1. Follow the guide [Installation on the Nagios® site with active checks](https://github.com/ccztux/modpd#installation-on-the-nagios-site-with-active-checks) and overwrite all existing files
2. Merge possible changes between the new sample config ```/usr/local/modpd/etc/modpd.sample.conf``` and your productive one ```/usr/local/modpd/etc/modpd.conf``` using the tool of your choice like ```vimdiff```.
3. Restart nagios ```service nagios restart```
4. Check if nagios is running ```service nagios status```
5. Restart the modpd daemon ```service modpd restart```
6. Check if the modpd daemon is running ```service modpd status```


# Example help output
```bash
Usage: modpd OPTIONS

Author:                 Christian Zettel (ccztux)
Last modification:      2020-02-26
Version:                2.1.3

Description:            modpd (Monitoring Obsessing Data Processor Daemon)

OPTIONS:
   -h           Shows this help.
   -c           Path to config file. (Default: /usr/local/modpd/etc/modpd.conf)
   -v           Shows detailed version information.
```


# Default sample config
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
#						2020-02-26
#
#  Version				2.1.3
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

# shellcheck disable=SC2034
# shellcheck disable=SC2154


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
obsessing_interface="nrdp"

# define the host, where check results should be sent to
obsessing_host="10.0.0.31"

# define the port, where the obsessing daemon is listening on
obsessing_port="443"



#--------------------------------------------------------------------
# NRDP specific settings (Needed in case obsessing_interface is nrdp)
#--------------------------------------------------------------------

# define the connection protocol
# (valid values: http|https)
nrdp_protocol="https"

# define the url path of the nrdp server
nrdp_url_path="/nrdp"

# define the nrdp token
nrdp_token="12345678"

# define the username, if nrdp basic auth is activated
nrdp_username="nrdpuser"

# define the password of the user you have defined in variable: nrdp_username with which we sould connect
nrdp_password="mySecret"



#--------------------------------------------------------------------
# NSCA specific settings (Needed in case obsessing_interface is nsca)
#--------------------------------------------------------------------

# define the path to the config file of send_nsca binary
nsca_config_file="/usr/local/nagios/etc/send_nsca.cfg"



#---------------------------------------------------------------------------------------
# Proxy settings (Needed in case obsessing_interface is nrdp and a proxy should be used)
#---------------------------------------------------------------------------------------

# enable proxy
proxy_enabled="0"

# username to authenticate on proxy server
proxy_username="ccztux"

# password to authenticate on proxy server
proxy_password="mySecret"

# proxy protocol
# (valid values: http|https)
proxy_protocol="https"

# proxy ip or hostname
proxy_ip="10.0.0.10"

# proxy port
proxy_port="3128"






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
log_to_file="1"

# enable log to stdout"
# (valid values: 1|0)
log_to_stdout="0"

# enable log to system logfile
# (valid values: 1|0)
log_to_syslog="0"

# enable log to system journal
# (valid values: 1|0)
log_to_journal="0"

# timestamp format for log messages
# (HINT: have a look at: 'man strftime')
log_timestamp_format="%Y-%m-%d %H:%M:%S"

# log invalid data
# (valid values: 1|0)
log_invalid_data="1"



#----------------
# Named pipe path
#----------------

# file name of named pipe
named_pipe_filename="${script_base_path}/var/rw/modpd.cmd"



#-------------
# Job settings
#-------------

# enable job timeout
job_timeout_enabled="1"

# job timeout in seconds (recommended: job_exec_interval * 2)
job_timeout="8"

# job execution interval in seconds
job_exec_interval="4"

# separator to separate job data
job_data_separator="<=#modpd#=>"

# job max bulk size
job_max_bulk_size="50"

# log unsuccessful job commands
# (valid values: 1|0)
job_command_log_nok="1"

# log timed out job commands
# (valid values: 1|0)
job_command_log_timeout="1"

# log successful job commands
# (valid values: 1|0)
job_command_log_ok="0"



#------
# Stats
#------

# enable stats logging
stats_enabled="1"

# interval in seconds when the stats should be logged
stats_interval="300"
```



# Example log snippets
## modpd daemon log snippet
```
[root@lab01]:~# service modpd status
modpd (PID 23925) is running                                [  OK  ]

[root@lab01]:~# service modpd stop
Stopping modpd                                             [  OK  ]

[root@lab01]:~# grep 23925 /usr/local/modpd/var/log/modpd.log
2020-02-26 09:32:55 |  23925 | checkLogHandlerRequirements | modpd 2.1.1 starting... (PID=23925)
2020-02-26 09:32:55 |  23925 | checkLogHandlerRequirements | We are using the config file: '/usr/local/modpd/etc/modpd.conf'.
2020-02-26 09:32:55 |  23925 |                     getUser | Get user which starts the script...
2020-02-26 09:32:55 |  23925 |                     getUser | modpd was started as user: 'nagios'.
2020-02-26 09:32:55 |  23925 |            checkBashVersion | Checking bash version...
2020-02-26 09:32:55 |  23925 |            checkBashVersion | Bash version: '4' meets requirements.
2020-02-26 09:32:55 |  23925 | checkAlreadyRunningInstance | Check if another instance of: 'modpd' is already running...
2020-02-26 09:32:55 |  23925 |                   checkLock | Check if lock file: '/usr/local/modpd/var/lock/modpd.lock' exists and if it is read/writeable...
2020-02-26 09:32:55 |  23925 |                   checkLock | Lock file doesnt exist.
2020-02-26 09:32:55 |  23925 | checkAlreadyRunningInstance | No other instance of: 'modpd' is currently running (Lockfile: '/usr/local/modpd/var/lock/modpd.lock' doesnt exist and no processes are running).
2020-02-26 09:32:55 |  23925 |                     setLock | Check if script lock directory: '/usr/local/modpd/var/lock' exists and permissions to set lock are ok...
2020-02-26 09:32:55 |  23925 |                     setLock | Script lock directory exists and permissions are ok.
2020-02-26 09:32:55 |  23925 |                     setLock | Setting lock...
2020-02-26 09:32:55 |  23925 |                     setLock | Setting lock was successful.
2020-02-26 09:32:55 |  23925 |              checkNamedPipe | Check if named pipe: '/usr/local/modpd/var/rw/modpd.cmd' exists and if it is read/writeable...
2020-02-26 09:32:55 |  23925 |              checkNamedPipe | Named pipe doesnt exist.
2020-02-26 09:32:55 |  23925 |             createNamedPipe | Creating named pipe...
2020-02-26 09:32:55 |  23925 |             createNamedPipe | Creating named pipe was successful.
2020-02-26 09:32:55 |  23925 |             buildJobCommand | Building job command...
2020-02-26 09:32:55 |  23925 |             buildJobCommand | We build the following job command: '/usr/bin/timeout --signal=TERM 8 /usr/bin/php /usr/local/modpd/libexec/send_nrdp.php --usestdin --token="[HIDDEN FOR SECURITY]" --url=https://nrdpuser:[HIDDEN FOR SECURITY]@172.20.102.45:443/nrdp'.
2020-02-26 09:32:55 |  23925 |                       _main | Ready to handle jobs...
2020-02-26 09:37:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 09:37:55 |  23925 |                    logStats | modpd is running: 0d 0h 5m 0s
2020-02-26 09:37:55 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 09:37:55 |  23925 |                    logStats | Handled host checks: '10276', handled service checks: '7500', invalid datasets received: '0'.
2020-02-26 09:42:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 09:42:55 |  23925 |                    logStats | modpd is running: 0d 0h 10m 0s
2020-02-26 09:42:55 |  23925 |                    logStats | Total processed jobs: '51', successful processed jobs: '51', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 09:42:55 |  23925 |                    logStats | Handled host checks: '10570', handled service checks: '7500', invalid datasets received: '0'.
2020-02-26 09:47:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 09:47:55 |  23925 |                    logStats | modpd is running: 0d 0h 15m 0s
2020-02-26 09:47:55 |  23925 |                    logStats | Total processed jobs: '51', successful processed jobs: '51', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 09:47:55 |  23925 |                    logStats | Handled host checks: '10263', handled service checks: '7517', invalid datasets received: '0'.
2020-02-26 09:52:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 09:52:55 |  23925 |                    logStats | modpd is running: 0d 0h 20m 0s
2020-02-26 09:52:55 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 09:52:55 |  23925 |                    logStats | Handled host checks: '10616', handled service checks: '7483', invalid datasets received: '0'.
2020-02-26 09:57:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 09:57:55 |  23925 |                    logStats | modpd is running: 0d 0h 25m 0s
2020-02-26 09:57:55 |  23925 |                    logStats | Total processed jobs: '52', successful processed jobs: '52', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 09:57:55 |  23925 |                    logStats | Handled host checks: '10446', handled service checks: '7556', invalid datasets received: '0'.
2020-02-26 10:02:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 10:02:55 |  23925 |                    logStats | modpd is running: 0d 0h 30m 0s
2020-02-26 10:02:55 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:02:55 |  23925 |                    logStats | Handled host checks: '9819', handled service checks: '7444', invalid datasets received: '0'.
2020-02-26 10:07:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 10:07:55 |  23925 |                    logStats | modpd is running: 0d 0h 35m 0s
2020-02-26 10:07:55 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:07:55 |  23925 |                    logStats | Handled host checks: '8381', handled service checks: '7506', invalid datasets received: '0'.
2020-02-26 10:12:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 10:12:55 |  23925 |                    logStats | modpd is running: 0d 0h 40m 0s
2020-02-26 10:12:55 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:12:55 |  23925 |                    logStats | Handled host checks: '8431', handled service checks: '7494', invalid datasets received: '0'.
2020-02-26 10:17:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 10:17:55 |  23925 |                    logStats | modpd is running: 0d 0h 45m 0s
2020-02-26 10:17:55 |  23925 |                    logStats | Total processed jobs: '51', successful processed jobs: '51', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:17:55 |  23925 |                    logStats | Handled host checks: '10034', handled service checks: '7575', invalid datasets received: '0'.
2020-02-26 10:22:56 |  23925 |                    logStats | ---- Stats for the last 301 seconds ----
2020-02-26 10:22:56 |  23925 |                    logStats | modpd is running: 0d 0h 50m 0s
2020-02-26 10:22:56 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:22:56 |  23925 |                    logStats | Handled host checks: '10330', handled service checks: '7425', invalid datasets received: '0'.
2020-02-26 10:27:55 |  23925 |                    logStats | ---- Stats for the last 299 seconds ----
2020-02-26 10:27:55 |  23925 |                    logStats | modpd is running: 0d 0h 55m 0s
2020-02-26 10:27:55 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:27:55 |  23925 |                    logStats | Handled host checks: '10255', handled service checks: '7523', invalid datasets received: '0'.
2020-02-26 10:32:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 10:32:55 |  23925 |                    logStats | modpd is running: 0d 1h 0m 0s
2020-02-26 10:32:55 |  23925 |                    logStats | Total processed jobs: '51', successful processed jobs: '51', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:32:55 |  23925 |                    logStats | Handled host checks: '10779', handled service checks: '7477', invalid datasets received: '0'.
2020-02-26 10:37:55 |  23925 |                    logStats | ---- Stats for the last 300 seconds ----
2020-02-26 10:37:55 |  23925 |                    logStats | modpd is running: 0d 1h 5m 0s
2020-02-26 10:37:55 |  23925 |                    logStats | Total processed jobs: '51', successful processed jobs: '51', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:37:55 |  23925 |                    logStats | Handled host checks: '10431', handled service checks: '7575', invalid datasets received: '0'.
2020-02-26 10:42:48 |  23925 |               signalHandler | Caught: 'SIGTERM', preparing for exiting...
2020-02-26 10:42:48 |  23925 |                    logStats | ---- Stats for the last 293 seconds ----
2020-02-26 10:42:48 |  23925 |                    logStats | modpd is running: 0d 1h 9m 53s
2020-02-26 10:42:48 |  23925 |                    logStats | Total processed jobs: '50', successful processed jobs: '50', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-26 10:42:48 |  23925 |                    logStats | Handled host checks: '10021', handled service checks: '7275', invalid datasets received: '0'.
2020-02-26 10:42:48 |  23925 |               signalHandler | Caught: 'EXIT', exiting script...
2020-02-26 10:42:48 |  23925 |              checkNamedPipe | Check if named pipe: '/usr/local/modpd/var/rw/modpd.cmd' exists and if it is read/writeable...
2020-02-26 10:42:48 |  23925 |              checkNamedPipe | Named pipe exists and it is read/writeable.
2020-02-26 10:42:48 |  23925 |             removeNamedPipe | Remove named pipe...
2020-02-26 10:42:48 |  23925 |             removeNamedPipe | Removing named pipe was successful.
2020-02-26 10:42:48 |  23925 |                   checkLock | Check if lock file: '/usr/local/modpd/var/lock/modpd.lock' exists and if it is read/writeable...
2020-02-26 10:42:48 |  23925 |                   checkLock | Lock file exists and it is read/writeable.
2020-02-26 10:42:48 |  23925 |                  removeLock | Removing lock...
2020-02-26 10:42:48 |  23925 |                  removeLock | Removing lock was successful.
2020-02-26 10:42:48 |  23925 |               signalHandler | Exitcode: '143'.
2020-02-26 10:42:48 |  23925 |               signalHandler | modpd was running: 0d 1h 9m 53s.
2020-02-26 10:42:48 |  23925 |               signalHandler | Bye, bye...
```


## modpd NEB module log snippet
```
[root@lab01]:~# grep -i modpd /usr/local/nagios/var/nagios.log
[1582272717] modpd: Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved, Version: 2.1.3
[1582272717] modpd: Starting...
[1582272717] Event broker module '/usr/local/nagios/include/modpd.o' initialized successfully.
[1582273017] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 10278 (OK: 10278/NOK: 0), Services: 7430 (OK: 7430/NOK: 0) ***
[1582273317] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 10149 (OK: 10149/NOK: 0), Services: 7425 (OK: 7425/NOK: 0) ***
[1582273617] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 10631 (OK: 10577/NOK: 54), Services: 7575 (OK: 7549/NOK: 26) ***
[1582273917] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 10323 (OK: 10323/NOK: 0), Services: 7425 (OK: 7425/NOK: 0) ***
[1582274217] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 10277 (OK: 10277/NOK: 0), Services: 7575 (OK: 7575/NOK: 0) ***
[1582274517] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 9073 (OK: 9073/NOK: 0), Services: 7425 (OK: 7425/NOK: 0) ***
[1582274817] modpd: *** Stats of processed checks for the last 300 seconds: Hosts: 8098 (OK: 8098/NOK: 0), Services: 7575 (OK: 7575/NOK: 0) ***
[1582274893] modpd: *** Stats of processed checks for the last 76 seconds: Hosts: 2566 (OK: 2566/NOK: 0), Services: 1949 (OK: 1949/NOK: 0) ***
[1582274893] modpd: The modpd NEB module was running 0d 0h 36m 16s
[1582274893] modpd: Bye, bye...
[1582274893] Event broker module '/usr/local/nagios/include/modpd.o' deinitialized successfully.
```
