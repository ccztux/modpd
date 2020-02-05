[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/master?label=shellcheck%28master%29)](https://travis-ci.org/ccztux/modpd)
[![Travis (.org) branch](https://img.shields.io/travis/ccztux/modpd/devel?label=shellcheck%28devel%29)](https://travis-ci.org/ccztux/modpd)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ccztux/modpd?label=latest%20release)](https://github.com/ccztux/modpd/releases/latest)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/ccztux/modpd?include_prereleases&label=latest%20pre-release)](https://github.com/ccztux/modpd/releases/tag/1.0.2-beta1)
[![GitHub](https://img.shields.io/github/license/ccztux/modpd?color=yellowgreen)](https://github.com/ccztux/modpd/blob/master/LICENSE)



# modpd
(**M**onitoring **O**bsessing **D**ata **P**rocessor **D**aemon)

You can use modpd with send_nrdp.php or send_nsca. It increases the performance of an existing Nagios 3.x.x installation greatly, because the obsessing commands will be executed by modpd and not by the nagios process itself. Nagios executes the obsessing command after every check, where obsessing is activated and then Nagios waits, till every obsessing command was executed successfully or timed out.



## It requires the following binaries:
- **bash** (Version >= 3)
- **whoami** to check the user who executes modpd
- **pgrep** to check if an instance of modpd is already running
- **date** for logging purposes (Only required if bash version < 4.2. Else printf bash builtin will be used.)
- **rm** to delete the named_pipe_filename
- **mkdir** to create directories
- **mkfifo** to create the named_pipe_filename
- **kill** to send kill signal to modpd
- **sleep** to do nothing :)



## Optionally used binaries:
- **logger** to log to the system log
- **systemd-cat** to log to the system journal
- **timeout** to start the obsessing jobs with a timeout value
- **php** in case obsessing_interface is nrdp



## Installation:

Download the latest tarball and extract it:

```bash
cd /tmp
wget "https://api.github.com/repos/ccztux/modpd/tarball" -O modpd.latest.tar.gz
tar -xvzf modpd.latest.tar.gz
cd ccztux-modpd-*
```


Copy the files:

```bash
cp -av ./usr/local/modpd/ /usr/local/
cp -av ./etc/logrotate.d/modpd /etc/logrotate.d/
```


Change the file ownership:

```bash
chown -R root:root /usr/local/modpd/
chown root:root /etc/logrotate.d/modpd
chmod 644 /etc/logrotate.d/modpd
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



## Example help output:
```
Usage: modpd OPTIONS

Author:                 Christian Zettel (ccztux)
Last modification:      2020-02-05
Version:                1.0.3-alpha1

Description:            modpd (Monitoring Obsessing Data Processor Daemon)

OPTIONS:
   -h           Shows this help.
   -c           Config file. (If undefined default value: '' will be used.)
   -l           Lock file. (If undefined default value: '' will be used.)
   -v           Shows detailed version information.
```



## Configuration variables (default):
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



## Example log:
