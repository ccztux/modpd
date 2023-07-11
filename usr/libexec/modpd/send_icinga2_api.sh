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
#  Description:			Send host/service checkresults to Icinga2 API
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


#----------------------
# Script info variables
#----------------------

script_name="${0##*/}"
script_author="Christian Zettel"
script_version="3.1.0"
script_description="Send host/service checkresults to Icinga2 API"
script_last_modification_date="2023-07-10"



#-----------------
# Global variables
#-----------------

api_host=
api_port=
api_username=
api_password=
host_name=
service_description=
exit_status=
output=
perfdata=
use_stdin=
delimiter=
raw_data=()
return_code="0"



#---------------
# Default values
#---------------

default_delimiter="\t"



#----------
# Functions
#----------

ePrintf()
{
	printf 'ERROR: %b\n' "${@}" >&2
}

setDefaultValues()
{
	delimiter="${delimiter:=${default_delimiter}}"
}

printUsage()
{
	setDefaultValues

	printf 'Usage: %s OPTIONS\n\n' "${script_name}"
	printf 'Author:\t\t\t%s\n' "${script_author}"
	printf 'Last modification:\t%s\n' "${script_last_modification_date}"
	printf 'Version:\t\t%s\n\n' "${script_version}"
	printf 'Description:\t\t%s\n\n' "${script_description}"
	printf 'API OPTIONS:\n'
	printf '   -a\t\tHostname or IP address of the hos providing the Icinga2 API\n'
	printf '   -P\t\tPort to use when connecting to the Icinga2 API\n'
	printf '   -u\t\tUsername\n'
	printf '   -p\t\tPassword\n\n'
	printf 'CHECK OPTIONS:\n'
	printf '   -H\t\tHosname\n'
	printf '   -S\t\tServicedescription\n'
	printf '   -E\t\tExit status\n'
	printf '   -O\t\tOutput\n\n'
	printf 'COMMON OPTIONS:\n'
	printf '   -d\t\tDelimiter (Default: %s)\n' "${default_delimiter}"
	printf '   -i\t\tUse stdin\n'
	printf '   -h\t\tShows this help.\n'
	printf '   -v\t\tShows detailed version information.\n'
}

printScriptInfos()
{
	printf 'Author:\t\t\t%s\n' "${script_author}"
	printf 'Last modification:\t%s\n' "${script_last_modification_date}"
	printf 'Version:\t\t%s\n\n' "${script_version}"
	printf 'Description:\t\t%s\n' "${script_description}"
}

checkOpts()
{
	if [ -z "${api_host}" ]
	then
		ePrintf "Mandatory argument: -a missing!\n"
		printUsage
		exit 100
	fi

	if [ -z "${api_port}" ]
	then
		ePrintf "Mandatory argument: -P missing!\n"
		printUsage
		exit 101
	fi

	if [ -z "${api_username}" ]
	then
		ePrintf "Mandatory argument: -u missing!\n"
		printUsage
		exit 102
	fi

	if [ -z "${api_password}" ]
	then
		ePrintf "Mandatory argument: -p missing!\n"
		printUsage
		exit 103
	fi

	if [ "${use_stdin}" != "1" ]
	then
		if [ -z "${host_name}" ]
		then
			ePrintf "Mandatory argument: -H missing!\n"
			printUsage
			exit 104
		fi

		if [ "${service_description_flag}" == "1" ] && [ -z "${service_description}" ]
		then
			ePrintf "Argument: -S is defined but has no value!\n"
			printUsage
			exit 105
		fi

		if [ -z "${exit_status}" ]
		then
			ePrintf "Mandatory argument: -s missing!\n"
			printUsage
			exit 106
		fi

		if [ -z "${output}" ]
		then
			ePrintf "Mandatory argument: -o missing!\n"
			printUsage
			exit 107
		fi
	fi
}

trim()
{
	# shellcheck disable=SC2295
	: "${1#"${1%%[!${2:-[:space:]}]*}"}"
	# shellcheck disable=SC2295
	printf '%s' "${_%"${_##*[!${2:-[:space:]}]}"}"
}

split()
{
	local arr=()
	IFS=$'\n' read -d "" -ra arr <<< "${2//$1/$'\n'}"
	printf '%s\n' "${arr[@]}"
}

prepareData()
{
	local rc=

	# host check
	if [ "${#raw_data[@]}" -eq "3" ]
	then
		host_name="$(trim "${raw_data[0]}")"
		exit_status="$(trim "${raw_data[1]}")"
		output="$(trim "${raw_data[2]}")"
	# host check containing delim in output
	elif [ "${#raw_data[@]}" -ge "4" ] && [[ "${raw_data[1]}" =~ ^([0-3])$ ]]
	then
		host_name="$(trim "${raw_data[0]}")"
		exit_status="$(trim "${raw_data[1]}")"
		# shellcheck disable=SC2124
		output="${raw_data[@]:2:${#raw_data[@]}}"
		output="$(trim "${output}")"
	# service check
	elif [ "${#raw_data[@]}" -ge "4" ] && [[ "${raw_data[2]}" =~ ^([0-3])$ ]]
	then
		host_name="$(trim "${raw_data[0]}")"
		service_description="$(trim "${raw_data[1]}")"
		exit_status="$(trim "${raw_data[2]}")"
		# shellcheck disable=SC2124
		output="${raw_data[@]:3:${#raw_data[@]}}"
		output="$(trim "${output}")"
	fi

	splitOutput
	sendData

	rc="${?}"

	if [ "${rc}" -gt "${return_code}" ]
	then
		return_code="${rc}"
	fi
}

stdinDataHandler()
{
	delimiter="$(printf '%b' "${delimiter}")"

	while read -r
	do
		mapfile -t raw_data< <(split "${delimiter}" "${REPLY}")

		resetData
		prepareData

		#echo "host_name: $host_name"
		#echo "service_description: $service_description"
		#echo "exit_status: $exit_status"
		#echo "output: $output"
		#echo "perfdata: $perfdata"
		#echo ------------------------------------
	done < /dev/stdin
}

splitOutput()
{
	if [[ "${output}" =~ ^(.*)(\|)(.*)$ ]]
	then
		output="$(trim "${BASH_REMATCH[1]}")"
		perfdata="$(trim "${BASH_REMATCH[3]}")"
	else
		output="$(trim "${output}")"
	fi
}

buildPostData()
{
	local check_type="${1}"

	printf '{ '
	printf '    "type": "%s",' "${check_type}"

	if [ "${check_type}" == "Service" ]
	then
		printf '    "filter": "host.name==\\"%s\\" && service.name==\\"%s\\"",' "${host_name}" "${service_description}"
	else
		printf '    "filter": "host.name==\\"%s\\"",' "${host_name}"
	fi

	printf '    "exit_status": %s,' "${exit_status}"
	printf '    "plugin_output": "%s",' "${output}"

	if [ -n "${perfdata}" ]
	then
		printf '    "performance_data": "%s",' "${perfdata}"
	fi

	printf '    "check_source": "%s",' "${HOSTNAME}"
	printf '    "pretty": true'
	printf '}'
}

sendData()
{
	local check_type="Service"
	local post_data=

	if [ -z "${service_description}" ]
	then
		check_type="Host"
	fi

	post_data="$(buildPostData "${check_type}")"

	#echo "post_data: $post_data"

	curl --insecure \
		 --silent \
		 --show-error \
		 --include \
		 --user "${api_username}:${api_password}" \
		 --header 'Accept: application/json' \
		 --request POST "https://${api_host}:${api_port}/v1/actions/process-check-result" \
		 --data "${post_data}" 2> /dev/null
}

resetData()
{
	host_name=
	service_description=
	exit_status=
	output=
	perfdata=
}

main()
{
	checkOpts
	setDefaultValues

	if [ "${use_stdin}" == "1" ]
	then
		if [ ! -t "0" ]
		then
			stdinDataHandler
		else
			ePrintf "No data on stdin available!"
			exit 1
		fi
	else
		prepareData
	fi

	exit "${return_code}"
}



#------
# Start
#------

if [ "${BASH_SOURCE[0]}" == "${0}" ]
then
	#------------
	# Get options
	#------------

	OPTERR="0"

	while getopts ":a:P:u:p:H:S:E:O:d:ihv" OPTION
	do
		case "${OPTION}" in
			a)
				api_host="${OPTARG}"
				;;
			P)
				api_port="${OPTARG}"
				;;
			u)
				api_username="${OPTARG}"
				;;
			p)
				api_password="${OPTARG}"
				;;
			H)
				host_name="${OPTARG}"
				;;
			S)
				service_description="${OPTARG}"
				service_description_flag="1"
				;;
			E)
				exit_status="${OPTARG}"
				;;
			O)
				output="${OPTARG}"
				;;
			d)
				delimiter="${OPTARG}"
				;;
			i)
				use_stdin="1"
				;;
			h)
				printUsage
				exit 200
				;;
			v)
				printScriptInfos
				exit 201
				;;
			\?)
				ePrintf "Invalid option: -${OPTARG}\n"
				printUsage
				exit 202
				;;
			:)
				ePrintf "Option: -${OPTARG} requires an argument!\n"
				printUsage
				exit 203
				;;
		esac
	done



	#----------------------------------------------------
	# In case of direct execution jump into main function
	#----------------------------------------------------

	main "${@}"
else
	#-----------------------------------------------------------------
	# In case of an include attempt, write error message and terminate
	#-----------------------------------------------------------------

	ePrintf "This is not a library. Execute this script directly!"
	return 110
fi
