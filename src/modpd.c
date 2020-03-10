/*******************************************************************************************************
*
*  Author:				Christian Zettel (ccztux)
*						2017-05-14
*						http://linuxinside.at
*
*  Copyright:			Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved
*
*  Project website:		https://github.com/ccztux/modpd
*
*  Last Modification:	Christian Zettel (ccztux)
*						2020-03-09
*
*  Version				2.1.3
*
*  Description:			NEB module to write obsessing data to unix socket
*						Based on example: nagioscore/module/helloworld.c
*
*  License:				GNU GPLv2
*
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
*
*******************************************************************************************************/


/* include (minimum required) event broker header files */
#include "nebmodules.h"
#include "nebcallbacks.h"

/* include other event broker header files that we need for our work */
#include "nebstructs.h"
#include "broker.h"

/* include some Nagios stuff as well */
#include "config.h"
#include "common.h"
#include "nagios.h"


/* specify event broker API version (required) */
NEB_API_VERSION(CURRENT_NEB_API_VERSION);


void *modpd_module_handle = NULL;

void log_modpd_stats(void);
int modpd_event_handler(int, void *);

unsigned int host_cmds_ok_counter = 0;
unsigned int host_cmds_nok_counter = 0;
unsigned int service_cmds_ok_counter = 0;
unsigned int service_cmds_nok_counter = 0;
time_t start_time;
time_t last_stats_logged;


/* this function gets called when the module is loaded by the event broker */
int nebmodule_init(int flags, char *args, nebmodule *handle)
{
	char temp_buffer[1024];
	unsigned int log_stats_interval = 300;
	time_t current_time;

	/* set the start time */
	time(&start_time);

	/* save our handle */
	modpd_module_handle = handle;

	/* set some info - this is completely optional, as Nagios doesn't do anything with this data */
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_TITLE, "modpd");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_AUTHOR, "Christian Zettel (ccztux)");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_TITLE, "Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_VERSION, "2.1.3");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_LICENSE, "GPL v2");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_DESC, "Obsessing NEB Module.");

	/* log module info to the Nagios log file */
	write_to_all_logs("modpd: Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved, Version: 2.1.3", NSLOG_INFO_MESSAGE);

	/* log a message to the Nagios log file */
	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: Starting...\n");
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	/* log a status message every 5 minutes (how's that for annoying? :-)) */
	time(&current_time);
	schedule_new_event(EVENT_USER_FUNCTION, TRUE, current_time + log_stats_interval, TRUE, log_stats_interval, NULL, TRUE, (void *)log_modpd_stats, NULL, 0);

	/* register to be notified of certain events... */
	neb_register_callback(NEBCALLBACK_HOST_CHECK_DATA, modpd_module_handle, 0, modpd_event_handler);
	neb_register_callback(NEBCALLBACK_SERVICE_CHECK_DATA, modpd_module_handle, 0, modpd_event_handler);

	return 0;
}


/* this function gets called when the module is unloaded by the event broker */
int nebmodule_deinit(int flags, int reason)
{
	char temp_buffer[1024];
	int days, hours, minutes, seconds;
	time_t current_time;
	unsigned int timediff;

	time(&current_time);
	timediff = current_time - start_time;

	/* deregister for all events we previously registered for... */
	neb_deregister_callback(NEBCALLBACK_HOST_CHECK_DATA, modpd_event_handler);
	neb_deregister_callback(NEBCALLBACK_SERVICE_CHECK_DATA, modpd_event_handler);

	/* write stats data to the Nagios log file */
	log_modpd_stats();

	get_time_breakdown(timediff, &days, &hours, &minutes, &seconds);

	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: The modpd NEB module was running %dd %dh %dm %ds", days, hours, minutes, seconds);
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: Bye, bye...\n");
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	return 0;
}


/* gets called every X minutes by an event in the scheduling queue */
void log_modpd_stats()
{
	char temp_buffer[1024];
	int days, hours, minutes, seconds;
	unsigned int host_cmds_total_counter = 0;
	unsigned int service_cmds_total_counter = 0;
	unsigned int uptime;
	unsigned int timediff;
	time_t current_time;

	/* calculation of the modpd NEB module uptime */
	time(&current_time);
	uptime = current_time - start_time;
	get_time_breakdown(uptime, &days, &hours, &minutes, &seconds);

	/* log our uptime to the Nagios log file */
	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: The modpd NEB module is running %dd %dh %dm %ds", days, hours, minutes, seconds);
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	/* calculation of stats data */
	host_cmds_total_counter = host_cmds_ok_counter + host_cmds_nok_counter;
	service_cmds_total_counter = service_cmds_ok_counter + service_cmds_nok_counter;

	/* calculation of the timediff between now and the last time stats were logged */
	if (last_stats_logged == '\x0') {
		timediff = current_time - start_time;
	} else {
		timediff = current_time - last_stats_logged;
	}

	/* log the stats to the Nagios log file */
	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: *** Stats of processed checks for the last %u seconds: Hosts: %u (OK: %u/NOK: %u), Services: %u (OK: %u/NOK: %u) ***\n", timediff, host_cmds_total_counter, host_cmds_ok_counter, host_cmds_nok_counter, service_cmds_total_counter, service_cmds_ok_counter, service_cmds_nok_counter);
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	/* reset stats variables */
	host_cmds_ok_counter = 0;
	host_cmds_nok_counter = 0;
	service_cmds_ok_counter = 0;
	service_cmds_nok_counter = 0;

	/* set the timestamp of the last stats logged */
	time(&last_stats_logged);

	return;
}


/* handle data from Nagios daemon */
int modpd_event_handler(int callback_type, void *data)
{
	nebstruct_host_check_data *hostdata = NULL;
	nebstruct_service_check_data *servicedata = NULL;
	host *host = NULL;
	service *service = NULL;
	char temp_buffer[32768];
	char output[32768];
	char modpd_fifo[34] = "/usr/local/modpd/var/rw/modpd.cmd";
	char separator[12] = "<=#modpd#=>";
   	int modpd_fifo_fd = 0;

	/* what type of event/data do we have? */
	switch(callback_type) {
		case NEBCALLBACK_HOST_CHECK_DATA:
			if ((hostdata = (nebstruct_host_check_data *) data)) {
				host = find_host(hostdata->host_name);

				if (hostdata->type == NEBTYPE_HOSTCHECK_PROCESSED && host->obsess_over_host == 1) {
					strcpy(output, "");

					if(hostdata->output != NULL) {
						strcat(output, hostdata->output);
					}
					if(hostdata->long_output != NULL) {
						strcat(output, "\\n");
						strcat(output, hostdata->long_output);
					}
					if(hostdata->perf_data != NULL) {
						strcat(output, " | ");
						strcat(output, hostdata->perf_data);
					}

					snprintf(temp_buffer, sizeof(temp_buffer) - 1, "%s%sNULL%s%d%s%s\n", hostdata->host_name, separator, separator, hostdata->state, separator, output);
					temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
   					modpd_fifo_fd = open(modpd_fifo, O_WRONLY|O_NONBLOCK);

   					if(write(modpd_fifo_fd, temp_buffer, strlen(temp_buffer)) != -1) {
						host_cmds_ok_counter++;
					} else {
						host_cmds_nok_counter++;
					}

   					close(modpd_fifo_fd);
				}
			}

			break;

		case NEBCALLBACK_SERVICE_CHECK_DATA:
			if ((servicedata = (nebstruct_service_check_data *) data)) {
				service = find_service(servicedata->host_name, servicedata->service_description);

				if (servicedata->type == NEBTYPE_SERVICECHECK_PROCESSED && service->obsess_over_service == 1) {
					strcpy(output, "");

					if(servicedata->output != NULL) {
						strcat(output, servicedata->output);
					}
					if(servicedata->long_output != NULL) {
						strcat(output, "\\n");
						strcat(output, servicedata->long_output);
					}
					if(servicedata->perf_data != NULL) {
						strcat(output, " | ");
						strcat(output, servicedata->perf_data);
					}

					snprintf(temp_buffer, sizeof(temp_buffer) - 1, "%s%s%s%s%d%s%s\n", servicedata->host_name, separator, servicedata->service_description, separator, servicedata->state, separator, output);
					temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
   					modpd_fifo_fd = open(modpd_fifo, O_WRONLY|O_NONBLOCK);

   					if(write(modpd_fifo_fd, temp_buffer, strlen(temp_buffer)) != -1) {
						service_cmds_ok_counter++;
					} else {
						service_cmds_nok_counter++;
					}

   					close(modpd_fifo_fd);
				}
			}

			break;

		default:
			break;
		}

	return 0;
}
