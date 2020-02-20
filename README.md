[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/master?label=shellcheck%28master%29)](https://travis-ci.org/ccztux/modpd)
[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/devel?label=shellcheck%28devel%29)](https://travis-ci.org/ccztux/modpd)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ccztux/modpd?label=latest%20release)](https://github.com/ccztux/modpd/releases/latest)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/ccztux/modpd?include_prereleases&label=latest%20pre-release)](https://github.com/ccztux/modpd/releases/tag/2.1.0-beta1)
[![GitHub](https://img.shields.io/github/license/ccztux/modpd?color=yellowgreen)](https://github.com/ccztux/modpd/blob/master/LICENSE)



# modpd
(**M**onitoring **O**bsessing **D**ata **P**rocessor **D**aemon)

You can use modpd with send_nrdp.php or send_nsca. It increases the performance of an existing Nagios 3.x.x installation greatly, because the obsessing commands will be executed by modpd and not by the nagios process itself. Nagios executes the obsessing command after every check, where obsessing is activated and then Nagios waits, till every obsessing command was executed successfully or timed out.



# Flowchart
![Alt](images/modpd.png)



# Registered trademarks
[Nagios®](https://www.nagios.org/) is a registered trademark


# Required binaries by modpd (the daemon part)
## It requires the following binaries:
- **bash** (version >= 3)
- **whoami** to check the user who has started modpd
- **pgrep** to check if an instance of modpd is already running
- **date** for logging purposes (Only required if bash version < 4.2, else bash's printf builtin will be used.)
- **rm** to delete the named_pipe_filename
- **mkdir** to create directories
- **mkfifo** to create the named_pipe_filename
- **kill** to send signals to modpd
- **sleep** to do nothing :)



## Optionally used binaries:
- **logger** to log to the system log
- **systemd-cat** to log to the system journal
- **timeout** to start the obsessing jobs with a timeout value
- **php** in case obsessing_interface is nrdp



# Required binaries for building the modpd NEB module
- **make** to build the modpd NEB module
- **gcc** to compile the modpd NEB module
- **install** to install the modpd NEB module
- **strip** to strip the modpd NEB module


# Installation:

Download the latest tarball and extract it:
```bash
cd /tmp
wget "https://api.github.com/repos/ccztux/modpd/tarball" -O modpd.latest.tar.gz
tar -xvzf modpd.latest.tar.gz
cd ccztux-modpd-*
```


Build the modpd NEB module:
```bash
make
make install
```



Add the modpd NEB module to your main nagios config file:
```bash
printf 'broker_module=/usr/local/nagios/include/modpd.o\n' >> /usr/local/nagios/etc/nagios.cfg
```



Set the eventbroker options (**event_broker_options=-1**) in your main nagios config file:
```bash
vim /usr/local/nagios/etc/nagios.cfg
```


Restart nagios:
```bash
service nagios restart
```



Check if nagios is running:
```bash
service nagios status
```



Check if the modpd NEB module was loaded by nagios:
```bash
grep -i modpd /usr/local/nagios/var/nagios.log
```



Copy the files:
```bash
cp -av ./usr/local/modpd/ /usr/local/
cp -av ./etc/logrotate.d/modpd /etc/logrotate.d/
cp -av ./etc/init.d/modpd /etc/init.d/
cp -av ./etc/sysconfig/modpd /etc/sysconfig/
```


Change the file ownership:
```bash
chown root:root /usr/local/modpd/
chown -R nagios:nagios /usr/local/modpd/*
chown root:root /etc/logrotate.d/modpd
chmod 644 /etc/logrotate.d/modpd
chown root:root /etc/init.d/modpd
chmod 755 /etc/init.d/modpd
chown root:root /etc/sysconfig/modpd
chmod 644 /etc/sysconfig/modpd
```


Copy the client you want to use (send_nsca | send_nrdp.php) to the libexec directory of modpd:
```
cp -av /path/where/your/client/exists /usr/local/modpd/libexec/
```


Edit the config:
```bash
vim /usr/local/modpd/etc/modpd.conf
```


Start modpd:
```bash
service modpd start
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



# Example help output:
```
Usage: modpd OPTIONS

Author:                 Christian Zettel (ccztux)
Last modification:      2020-02-18
Version:                2.1.0-beta1

Description:            modpd (Monitoring Obsessing Data Processor Daemon)

OPTIONS:
   -h           Shows this help.
   -c           Path to config file. (Default: /usr/local/modpd/etc/modpd.conf)
   -v           Shows detailed version information.
```



# Configuration variables (default):
```bash
#---------
# Logging:
#---------

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



#------------
# Named pipe:
#------------

# file name of named pipe
named_pipe_filename="${script_base_path}/var/rw/modpd.cmd"



#--------------
# Job settings:
#--------------

# enable job timeout
job_timeout_enabled="1"

# job timeout in seconds (recommended: job_exec_interval * 2)
job_timeout="8"

# job execution interval in seconds
job_exec_interval="4"

# separator to separate job data (ONLY MODIFY THIS IF YOU KNOW WHAT YOU DO!!!)
job_data_separator="<==##modpd##==>"

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



#--------------------
# Obsessing settings:
#--------------------

# define the obsessing interface
# (valid values: nrdp|nsca)
obsessing_interface="nrdp"

# define the host, where check results should be sent to
obsessing_host="10.0.0.31"

# define the port, where the obsessing daemon is listening on
obsessing_port="443"



#------------------------
# NRDP specific settings:
#------------------------

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



#------------------------
# NSCA specific settings:
#------------------------

# define the path to the config file of send_nsca binary
nsca_config_file="/usr/local/nagios/etc/send_nsca.cfg"



#----------------
# Proxy settings:
#----------------

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



#-----------
# Statistic:
#-----------

# enable statistic logging
statistic_enabled="1"

# interval in seconds on which the statistic should be logged
statistic_interval="300"
```



# Example log:
```
2020-02-18 10:14:45 |   1677 | checkLogHandlerRequirements | modpd 2.1.0-beta1 starting... (PID=1677)
2020-02-18 10:14:45 |   1677 | checkLogHandlerRequirements | We are using config file: '/usr/local/modpd/etc/modpd.conf'.
2020-02-18 10:14:45 |   1677 |                     getUser | Get user which starts the script...
2020-02-18 10:14:45 |   1677 |                     getUser | modpd was started as user: 'nagios'.
2020-02-18 10:14:45 |   1677 |            checkBashVersion | Checking bash version...
2020-02-18 10:14:45 |   1677 |            checkBashVersion | Bash version: '4' meets requirements.
2020-02-18 10:14:45 |   1677 | checkAlreadyRunningInstance | Check if another instance of: 'modpd' is already running...
2020-02-18 10:14:45 |   1677 |                   checkLock | Check if lock file: '/usr/local/modpd/var/lock/modpd.lock' exists and if it is read/writeable...
2020-02-18 10:14:45 |   1677 |                   checkLock | Lock file doesnt exist.
2020-02-18 10:14:45 |   1677 | checkAlreadyRunningInstance | No other instance of: 'modpd' is currently running (Lockfile: '/usr/local/modpd/var/lock/modpd.lock' doesnt exist and no processes are running).
2020-02-18 10:14:45 |   1677 |                     setLock | Check if script lock directory: '/usr/local/modpd/var/lock' exists and permissions to set lock are ok...
2020-02-18 10:14:45 |   1677 |                     setLock | Script lock directory exists and permissions are ok.
2020-02-18 10:14:45 |   1677 |                     setLock | Setting lock...
2020-02-18 10:14:45 |   1677 |                     setLock | Setting lock was successful.
2020-02-18 10:14:45 |   1677 |              checkNamedPipe | Check if named pipe: '/usr/local/modpd/var/rw/modpd.cmd' exists and if it is read/writeable...
2020-02-18 10:14:45 |   1677 |              checkNamedPipe | Named pipe doesnt exist.
2020-02-18 10:14:45 |   1677 |             createNamedPipe | Creating named pipe...
2020-02-18 10:14:45 |   1677 |             createNamedPipe | Creating named pipe was successful.
2020-02-18 10:14:45 |   1677 |             buildJobCommand | Building job command...
2020-02-18 10:14:45 |   1677 |             buildJobCommand | We build the following job command: '/usr/bin/timeout --signal=TERM 8 /usr/bin/php /usr/local/modpd/libexec/send_nrdp.php --usestdin --token="[HIDDEN FOR SECURITY]" --url=https:/
/nrdpuser:[HIDDEN FOR SECURITY]@172.20.102.45:443/nrdp'.
2020-02-18 10:14:45 |   1677 |                       _main | Ready to handle jobs...
2020-02-18 10:19:45 |   1677 |              printStatistic | - Statistic data - modpd is running: '300' seconds
2020-02-18 10:19:45 |   1677 |              printStatistic | - Statistic data - Total processed jobs: '51', successful processed jobs: '51', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-18 10:19:45 |   1677 |              printStatistic | - Statistic data - Handled host checks: '7804', handled service checks: '4400', invalid datasets received: '0'.
2020-02-18 10:24:45 |   1677 |              printStatistic | - Statistic data - modpd is running: '600' seconds
2020-02-18 10:24:45 |   1677 |              printStatistic | - Statistic data - Total processed jobs: '60', successful processed jobs: '60', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-18 10:24:45 |   1677 |              printStatistic | - Statistic data - Handled host checks: '10255', handled service checks: '7525', invalid datasets received: '0'.
2020-02-18 10:29:45 |   1677 |              printStatistic | - Statistic data - modpd is running: '900' seconds
2020-02-18 10:29:45 |   1677 |              printStatistic | - Statistic data - Total processed jobs: '57', successful processed jobs: '57', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-18 10:29:45 |   1677 |              printStatistic | - Statistic data - Handled host checks: '10233', handled service checks: '7425', invalid datasets received: '0'.
2020-02-18 10:34:45 |   1677 |              printStatistic | - Statistic data - modpd is running: '1200' seconds
2020-02-18 10:34:45 |   1677 |              printStatistic | - Statistic data - Total processed jobs: '57', successful processed jobs: '57', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-18 10:34:45 |   1677 |              printStatistic | - Statistic data - Handled host checks: '10626', handled service checks: '7575', invalid datasets received: '0'.
2020-02-18 10:39:45 |   1677 |              printStatistic | - Statistic data - modpd is running: '1500' seconds
2020-02-18 10:39:45 |   1677 |              printStatistic | - Statistic data - Total processed jobs: '53', successful processed jobs: '53', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-18 10:39:46 |   1677 |              printStatistic | - Statistic data - Handled host checks: '10578', handled service checks: '7500', invalid datasets received: '0'.
2020-02-18 10:44:45 |   1677 |              printStatistic | - Statistic data - modpd is running: '1800' seconds
2020-02-18 10:44:45 |   1677 |              printStatistic | - Statistic data - Total processed jobs: '51', successful processed jobs: '51', unsuccessful processed jobs: '0', timed out jobs: '0'.
2020-02-18 10:44:45 |   1677 |              printStatistic | - Statistic data - Handled host checks: '10350', handled service checks: '7463', invalid datasets received: '0'.
```
