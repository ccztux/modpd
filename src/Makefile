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
#						2023-01-09
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


# Source code directories
NAGIOS3_DIR=./nagios3
NAEMON_DIR=./naemon



all:	neb-nagios3 neb-naemon

neb-nagios3:
	cd $(NAGIOS3_DIR) && $(MAKE) neb-nagios3

neb-naemon:
	cd $(NAEMON_DIR) && $(MAKE) neb-naemon



clean: clean-neb-nagios3 clean-neb-naemon

clean-neb-nagios3:
	cd $(NAGIOS3_DIR) && $(MAKE) clean-neb-nagios3

clean-neb-naemon:
	cd $(NAEMON_DIR) && $(MAKE) clean-neb-naemon



install: install-neb-nagios3 install-neb-naemon

install-neb-nagios3:
	cd $(NAGIOS3_DIR) && $(MAKE) install-neb-nagios3

install-neb-naemon:
	cd $(NAEMON_DIR) && $(MAKE) install-neb-naemon



uninstall: uninstall-neb-nagios3 uninstall-neb-naemon

uninstall-neb-nagios3:
	cd $(NAGIOS3_DIR) && $(MAKE) uninstall-neb-nagios3

uninstall-neb-naemon:
	cd $(NAEMON_DIR) && $(MAKE) uninstall-neb-naemon
