#!/usr/bin/env bash

#========================================================================================================
#
#  Author:		Christian Zettel (ccztux)
#			2017-05-14
#			http://linuxinside.at
#
#  Copyright:		Copyright © 2017 Christian Zettel (ccztux), all rights reserved
#
#  Project website:	https://github.com/ccztux/modpd
#
#  Last Modification:	Christian Zettel (ccztux)
#			2017-10-03
#
#  Description:		modpd (Monitoring Obsessing Data Processor Daemon)
#
#  License:		GNU GPLv3
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#  !!! DONT DELETE THIS FILE, because its the database for check_modpd !!!
#
#========================================================================================================

# shellcheck disable=SC2034

# shows how long modpd is running in seconds
modpd_runtime="3"

# shows how much nrdp or nsca jobs where handled in one statistic data period (300 seconds)
script_job_counter_total="0"

# shows how much nrdp or nsca jobs where handled successfully in one statistic data period (300 seconds)
script_job_counter_ok="0"

# shows how much nrdp or nsca jobs where handled unsuccessfully in one statistic data period (300 seconds)
script_job_counter_nok="0"

# shows how much nrdp or nsca jobs timed out in one statistic data period (300 seconds)
script_job_counter_timeout="0"

# shows how much host checks where handled in one statistic data period (300 seconds)
script_host_counter="0"

# shows how much service checks where handled in one statistic data period (300 seconds)
script_service_counter="0"

# shows how much invalid datasets where received in one statistic data period (300 seconds)
script_invalid_data_counter="0"
