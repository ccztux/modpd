#!/usr/bin/env bash

#===================================================================================================
#
# Author:		Christian Zettel
#				2019-07-24
#
# Last Mod:		Christian Zettel
#				2019-08-01
#
# Description:	Script to change version strings in all files recursively.
#
# Version:		1.1.0
#
#===================================================================================================


#------------------
# Script info vars:
#------------------

script_name="${0##*/}"
script_argc="${#}"
script_pid="${$}"
script_author="Christian Zettel"
script_version="1.1.0"
script_description="Script to change version strings in all files recursively."
script_last_modification_date="2019-08-01"



#-------------
# Global vars:
#-------------

old_version="${1}"
new_version="${2}"
dry_run="${3:-1}"
exclude_list=()
affected_files=()
base_path="./"



#-----------
# Functions:
#-----------

printUsage()
{
	printf 'Usage: %s <arg1> <arg2> [arg3]\n\n' "${script_name}"
	printf '\targ1: old version string which should be replaced\n'
	printf '\targ2: new version string\n'
	printf '\targ3: dry run (shows affected files only) Valid values: 0|1 (Default: 1)\n\n'
	printf 'Example: %s 3.4.1 3.4.2 1\n' "${script_name}"
}

checkOpts()
{
	if [ "${script_argc}" -lt "2" ]
	then
		printUsage
		exit 100
	fi

	if [ "${old_version}" == "${new_version}" ]
	then
		printf 'ERROR: old_version: (%s) == new_version (%s)\n\n' "${old_version}" "${new_version}"
		printUsage
		exit 101
	fi

	if [[ ! "${dry_run}" =~ ^(0|1)$ ]]
	then
		printUsage
		exit 102
	fi
}

buildExcludeString()
{
	local ignore_file=".gitignore"
	local changelog_file="CHANGELOG"

	exclude_list+=("${script_name}" "${ignore_file}" "${changelog_file}")

	if [ -f "${base_path%%/*}/${ignore_file}" ]
	then
		exclude_list+=($(cat "${base_path%%/*}/${ignore_file}"))
	fi
}

isExcluded()
{
	local file_name="${1}"
	local file=

	for file in "${exclude_list[@]}"
	do
		if [ "${file}" == "${file_name}" ] || [ "${file}" == "${file_name##*/}" ]
		then
			return 0
		fi
	done

	return 1
}

getAffectedFiles()
{
	local file=
	local files=($(find "${base_path}" -type f -not -path "*/.git/*" -not -path "*/images/*"))

	for file in "${!files[@]}"
	do
		if isExcluded "${files[${file}]}"
		then
			unset files[${file}]
		else
			if grep -q "${old_version}" "${files[${file}]}"
			then
				affected_files+=("${files[${file}]}")
			fi
		fi
	done
}

processAffectedFiles()
{
	local file=

	for file in "${affected_files[@]}"
	do
		if [ "${dry_run}" != "1" ]
		then
			if sed -i "s/${old_version}/${new_version}/g" "${file}"
			then
				printf 'Changing version string in file: '\''%s'\'' was successful\n' "${file}"
			else
				printf 'Changing version string in file: '\''%s'\'' was NOT successful\n' "${file}"
			fi
		else
			printf 'Version string found in file: '\''%s'\''\n' "${file}"
		fi
	done
}



#-------
# Start:
#-------

checkOpts
buildExcludeString
getAffectedFiles
processAffectedFiles
