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
#						2021-01-07
#
#  Version				3.0.0
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



all:	modpd-nagios3 modpd-naemon

modpd-nagios3:
	cd $(SRC_DIR) && $(MAKE) modpd-nagios3

modpd-naemon:
	cd $(SRC_DIR) && $(MAKE) modpd-naemon



clean: clean-modpd-nagios3 clean-modpd-naemon

clean-modpd-nagios3:
	cd $(SRC_DIR) && $(MAKE) clean-modpd-nagios3

clean-modpd-naemon:
	cd $(SRC_DIR) && $(MAKE) clean-modpd-naemon



install: install-modpd-nagios3 install-modpd-naemon

install-modpd-nagios3:
	cd $(SRC_DIR) && $(MAKE) install-modpd-nagios3

install-modpd-naemon:
	cd $(SRC_DIR) && $(MAKE) install-modpd-naemon



uninstall: uninstall-modpd-nagios3 uninstall-modpd-naemon

uninstall-modpd-nagios3:
	cd $(SRC_DIR) && $(MAKE) uninstall-modpd-nagios3

uninstall-modpd-naemon:
	cd $(SRC_DIR) && $(MAKE) uninstall-modpd-naemon
