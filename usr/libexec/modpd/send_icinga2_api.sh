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
#						2023-10-04
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
script_last_modification_date="2023-10-04"



#-----------------
# Global variables
#-----------------

api_url_scheme=
api_host=
api_port=
api_username=
api_password=
host_name=
service_description=
exit_status=
output=
perfdata=
use_stdin_flag=
delimiter=
debug_flag=
raw_data=()



#---------------
# Default values
#---------------

default_delimiter="\t"
default_api_url_scheme="https"



#----------
# Functions
#----------

ePrintf()
{
	printf 'ERROR: %b\n' "${@}" >&2
}

printDebugMessage()
{
	local debug_message="${1}"

	if [ "${debug_flag}" != "1" ]
	then
		return
	fi

	if [ -z "${debug_message}" ]
	then
		if [ ! -t "0" ]
		then
			while read -r
			do
				printDebugMessage "${REPLY}"
			done < /dev/stdin
		fi
	fi

	printf 'DEBUG: %b\n' "${debug_message}" >&2
}

setDefaultValues()
{
	delimiter="${delimiter:=${default_delimiter}}"
	api_url_scheme="${api_url_scheme:=${default_api_url_scheme}}"
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
	printf '   -s\t\tURL scheme which should be used to connect (Default: %s)\n' "${default_api_url_scheme}"
	printf '   -a\t\tHostname or IP address of the host providing the Icinga2 API\n'
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
	printf '   -D\t\tDebug\n'
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

	if [ "${use_stdin_flag}" != "1" ]
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

join()
{
	local delimiter="${1:-}"
	local string="${2:-}"

	if shift 2
	then
		printf '%s' "${string}" "${@/#/${delimiter}}"
	fi
}

prepareData()
{
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

	printDebugMessage "host_name: ${host_name}"
	printDebugMessage "service_description: ${service_description}"
	printDebugMessage "exit_status: ${exit_status}"
	printDebugMessage "output: ${output}"
	printDebugMessage "perfdata: ${perfdata}\n"

	sendData &

	printDebugMessage "------------------------------------------------------------------------\n"
}

stdinDataHandler()
{
	delimiter="$(printf '%b' "${delimiter}")"

	while read -r
	do
		mapfile -t raw_data < <(split "${delimiter}" "${REPLY}")
		resetData
		prepareData
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
	local filter=
	local check_source="${HOSTNAME}"
	local pretty="true"
	local jq_cmd=()

	if [ "${check_type}" == "Service" ]
	then
		filter="host.name==\\\"${host_name}\\\" && service.name==\\\"${service_description}\\\""
	else
		filter="host.name==\\\"${host_name}\\\""
	fi

	jq_cmd+=("jq -M -n --arg type \"${check_type}\" \
					   --arg filter \"${filter}\" \
					   --argjson exit_status \"${exit_status}\" \
					   --arg plugin_output \"${output}\" ")

	if [ -n "${perfdata}" ]
	then
		jq_cmd+=("--arg performance_data \"${perfdata}\" ")
	fi

	jq_cmd+=("--arg check_source \"${check_source}\" \
			  --argjson pretty \"${pretty}\" \
			  '\$ARGS.named'")

	# shellcheck disable=SC2068
	echo "jq_cmd: $(join " " ${jq_cmd[@]})" | printDebugMessage
	# shellcheck disable=SC2294
	eval "${jq_cmd[@]}"
}

sendData()
{
	local check_type="Service"
	local curl_debug_opts="--output /dev/null"
	local curl_data_opt="--data '@${post_data_file}'"
	local curl_output_opt=
	local curl_cmd=()
	local post_data=()
	local post_data_file=
	post_data_file="$(mktemp "/tmp/${script_name%%.*}.postdata.XXXXXX")"

	if [ -z "${service_description}" ]
	then
		check_type="Host"
	fi

	if [ "${debug_flag}" == "1" ]
	then
		curl_output_opt=
		curl_debug_opts="--show-error --include --verbose"
	fi

	mapfile -t post_data < <(buildPostData "${check_type}")
	printf '%s\n' "${post_data[@]}" > "${post_data_file}"

	curl_cmd=("curl --insecure \
					--connect-timeout 2 \
					--max-time 4 \
					--silent \
					--fail \
					--user \"${api_username}:${api_password}\" \
					--header 'Accept: application/json' \
					--request POST \"${api_url_scheme}://${api_host}:${api_port}/v1/actions/process-check-result\" \
					${curl_output_opt} \
					${curl_debug_opts} \
					${curl_data_opt}")

	printDebugMessage "post_data:\n$(printf '%s\n' "${post_data[@]}")\n"
	# shellcheck disable=SC2068
	printDebugMessage "curl_cmd: $(join " " ${curl_cmd[@]})\n"

	if [ "${debug_flag}" != "1" ]
	then
		# shellcheck disable=SC2294
		eval "${curl_cmd[@]}"
	else
		# shellcheck disable=SC2145,SC2294
		eval "${curl_cmd[@]} |& printDebugMessage"
	fi

	if [ -f "${post_data_file}" ]
	then
		rm "${post_data_file}"
	fi
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

	if [ "${use_stdin_flag}" == "1" ]
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

	exit 0
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

	while getopts ":s:a:P:u:p:H:S:E:O:d:iDhv" OPTION
	do
		case "${OPTION}" in
			s)
				api_url_scheme="${OPTARG}"
				;;
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
				use_stdin_flag="1"
				;;
			D)
				debug_flag="1"
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
