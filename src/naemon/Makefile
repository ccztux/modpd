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
#						2024-05-22
#
#  Version				3.0.1
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
SRC_INCLUDE=../../naemon

CC=gcc
MOD_CFLAGS=-fPIC
CFLAGS=`pkg-config --cflags glib-2.0` -g -O2 -DHAVE_CONFIG_H
MOD_LDFLAGS=-shared
LDFLAGS=`pkg-config --libs glib-2.0`
LIBS=

prefix=/usr/lib64/modpd
exec_prefix=${prefix}
INSTALL=/usr/bin/install -c
INSTALL_DIR_OPTS=-m 755 -o root -g root -d
INSTALL_FILE_OPTS=-s -m 644 -o 644 -g root

DESTDIR=${prefix}

all:	neb-naemon

neb-naemon: modpd_naemon.c
	$(CC) -I $(SRC_INCLUDE) $(MOD_CFLAGS) $(CFLAGS) -o modpd_naemon.o modpd_naemon.c $(MOD_LDFLAGS) $(LDFLAGS) $(LIBS)

clean-neb-naemon:
	rm -f modpd_naemon.o
	rm -f *~ *.*~

install-neb-naemon:
	$(INSTALL) $(INSTALL_DIR_OPTS) -d $(DESTDIR)
	$(INSTALL) $(INSTALL_FILE_OPTS) modpd_naemon.o $(DESTDIR)

uninstall-neb-naemon:
	rm -f $(DESTDIR)/modpd_naemon.o
