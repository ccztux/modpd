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
#  Description:			Makefile for the modpd NEB module
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


# Source code directory
SRC_DIR=./src


INSTALL=/usr/bin/install -c
INSTALL_DIR_OPTS=-m 755 -o root -g root -d
INSTALL_VAR_LIB_DIR_OPTS=-m 775 -o modpd -g modpd -d
INSTALL_VAR_LIB_LOCK_DIR_OPTS=-m 755 -o modpd -g modpd -d
INSTALL_VAR_LOG_DIR_OPTS=-m 755 -o modpd -g root -d
INSTALL_BIN_OPTS=-m 755 -o root -g root
INSTALL_FILE_OPTS=-m 644 -o root -g root


all:	neb-nagios3 neb-naemon

neb-nagios3:
	cd $(SRC_DIR) && $(MAKE) neb-nagios3

neb-naemon:
	cd $(SRC_DIR) && $(MAKE) neb-naemon



clean: clean-neb-nagios3 clean-neb-naemon

clean-neb-nagios3:
	cd $(SRC_DIR) && $(MAKE) clean-neb-nagios3

clean-neb-naemon:
	cd $(SRC_DIR) && $(MAKE) clean-neb-naemon



install: install-neb-nagios3 install-neb-naemon install-modpd

install-neb-nagios3:
	cd $(SRC_DIR) && $(MAKE) install-neb-nagios3

install-neb-naemon:
	cd $(SRC_DIR) && $(MAKE) install-neb-naemon

install-modpd:
	$(INSTALL) $(INSTALL_DIR_OPTS) /etc/modpd/
	$(INSTALL) $(INSTALL_DIR_OPTS) /usr/libexec/modpd/
	$(INSTALL) $(INSTALL_VAR_LIB_DIR_OPTS) /var/lib/modpd/
	$(INSTALL) $(INSTALL_VAR_LIB_LOCK_DIR_OPTS) /var/lib/modpd/lock/
	$(INSTALL) $(INSTALL_VAR_LIB_DIR_OPTS) /var/lib/modpd/rw/
	$(INSTALL) $(INSTALL_VAR_LOG_DIR_OPTS) /var/log/modpd/

	$(INSTALL) $(INSTALL_FILE_OPTS) ./etc/logrotate.d/modpd /etc/logrotate.d/modpd
	if [ ! -f /etc/modpd/modpd.conf ] ;then $(INSTALL) $(INSTALL_FILE_OPTS) ./etc/modpd/modpd.conf /etc/modpd/modpd.conf ; fi
	$(INSTALL) $(INSTALL_FILE_OPTS) ./etc/modpd/modpd.sample.conf /etc/modpd/modpd.sample.conf
	$(INSTALL) $(INSTALL_FILE_OPTS) ./etc/sysconfig/modpd /etc/sysconfig/modpd
	$(INSTALL) $(INSTALL_BIN_OPTS) ./usr/bin/modpd /usr/bin/modpd
	$(INSTALL) $(INSTALL_FILE_OPTS) ./usr/lib/systemd/system/modpd.service /usr/lib/systemd/system/modpd.service



uninstall: uninstall-neb-nagios3 uninstall-neb-naemon

uninstall-neb-nagios3:
	cd $(SRC_DIR) && $(MAKE) uninstall-neb-nagios3

uninstall-neb-naemon:
	cd $(SRC_DIR) && $(MAKE) uninstall-neb-naemon


.PHONY:	clean
