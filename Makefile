#========================================================================================================
#
#  Author:				Christian Zettel (ccztux)
#						2017-05-14
#						http://linuxinside.at
#
#  Copyright:			Copyright © 2017 Christian Zettel (ccztux), all rights reserved
#
#  Project website:		https://github.com/ccztux/modpd
#
#  Last Modification:	Christian Zettel (ccztux)
#						2020-02-06
#
#  Version				1.0.3-alpha5
#
#  Description:			Makefile for the modpd NEB module
#
#  License:				GNU GPLv3
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
#========================================================================================================


# Source code directory
SRC_DIR=./src



all:	modpd.o

modpd.o:
	cd $(SRC_DIR) && $(MAKE)

clean:
	cd $(SRC_DIR) && $(MAKE) clean

install:
	cd $(SRC_DIR) && $(MAKE) install
