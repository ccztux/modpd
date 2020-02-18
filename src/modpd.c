/*******************************************************************************************************
*
*  Author:				Christian Zettel (ccztux)
*						2017-05-14
*						http://linuxinside.at
*
*  Copyright:			Copyright © 2017 Christian Zettel (ccztux), all rights reserved
*
*  Project website:		https://github.com/ccztux/modpd
*
*  Last Modification:	Christian Zettel (ccztux)
*						2020-02-18
*
*  Version				2.0.1-beta1
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

void modpd_status_message(void);
int modpd_event_handler(int, void *);

unsigned int host_cmds_ok_counter = 0;
unsigned int host_cmds_nok_counter = 0;
unsigned int service_cmds_ok_counter = 0;
unsigned int service_cmds_nok_counter = 0;


/* this function gets called when the module is loaded by the event broker */
int nebmodule_init(int flags, char *args, nebmodule *handle) {
	char temp_buffer[1024];
	time_t current_time;
	unsigned int interval;

	/* save our handle */
	modpd_module_handle = handle;

	/* set some info - this is completely optional, as Nagios doesn't do anything with this data */
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_TITLE, "modpd");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_AUTHOR, "Christian Zettel (ccztux)");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_TITLE, "Copyright (c) 2017 Christian Zettel");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_VERSION, "2.0.1-beta1");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_LICENSE, "GPL v2");
	neb_set_module_info(modpd_module_handle, NEBMODULE_MODINFO_DESC, "Obsessing NEB Module.");

	/* log module info to the Nagios log file */
	write_to_all_logs("modpd: Copyright (c) 2017 Christian Zettel (ccztux), Version: 2.0.1-beta1", NSLOG_INFO_MESSAGE);

	/* log a message to the Nagios log file */
	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: Starting...\n");
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	/* log a status message every 15 minutes (how's that for annoying? :-)) */
	time(&current_time);
	interval = 300;
	schedule_new_event(EVENT_USER_FUNCTION, TRUE, current_time + interval, TRUE, interval, NULL, TRUE, (void *)modpd_status_message, NULL, 0);

	/* register to be notified of certain events... */
	neb_register_callback(NEBCALLBACK_HOST_CHECK_DATA, modpd_module_handle, 0, modpd_event_handler);
	neb_register_callback(NEBCALLBACK_SERVICE_CHECK_DATA, modpd_module_handle, 0, modpd_event_handler);

	return 0;
	}


/* this function gets called when the module is unloaded by the event broker */
int nebmodule_deinit(int flags, int reason) {
	char temp_buffer[1024];

	/* deregister for all events we previously registered for... */
	neb_deregister_callback(NEBCALLBACK_HOST_CHECK_DATA, modpd_event_handler);
	neb_deregister_callback(NEBCALLBACK_SERVICE_CHECK_DATA, modpd_event_handler);

	/* write statistic data to the Nagios log file */
	modpd_status_message();

	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: Bye, bye...\n");
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	return 0;
	}


/* gets called every X minutes by an event in the scheduling queue */
void modpd_status_message() {
	char temp_buffer[1024];
	unsigned int host_cmds_total_counter = 0;
	unsigned int service_cmds_total_counter = 0;

	host_cmds_total_counter = host_cmds_ok_counter + host_cmds_nok_counter;
	service_cmds_total_counter = service_cmds_ok_counter + service_cmds_nok_counter;

	/* log a message to the Nagios log file */
	snprintf(temp_buffer, sizeof(temp_buffer) - 1, "modpd: Processed data statistic: Hosts: %u (OK: %u/NOK: %u), Services: %u (OK: %u/NOK: %u).\n", host_cmds_total_counter, host_cmds_ok_counter, host_cmds_nok_counter, service_cmds_total_counter, service_cmds_ok_counter, service_cmds_nok_counter);
	temp_buffer[sizeof(temp_buffer) - 1] = '\x0';
	write_to_all_logs(temp_buffer, NSLOG_INFO_MESSAGE);

	/* reset status variables */
	host_cmds_ok_counter = 0;
	host_cmds_nok_counter = 0;
	service_cmds_ok_counter = 0;
	service_cmds_nok_counter = 0;

	return;
	}


/* handle data from Nagios daemon */
int modpd_event_handler(int callback_type, void *data) {
	nebstruct_host_check_data *hostdata = NULL;
	nebstruct_service_check_data *servicedata = NULL;
	host *host = NULL;
	service *service = NULL;
	char temp_buffer[32768];
	char output[32768];
	char modpd_fifo[34] = "/usr/local/modpd/var/rw/modpd.cmd";
	char separator[20] = "<=#modpd#=>";
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
