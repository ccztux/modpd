#========================================================================================================
#
#  Author:				Christian Zettel (ccztux)
#						2017-05-14
#						http://linuxinside.at
#
#  Copyright:			Copyright © 2017-2020 Christian Zettel (ccztux), all rights reserved
#
#  Project website:		https://github.com/ccztux/modpd
#
#  Last Modification:	Christian Zettel (ccztux)
#						2020-02-20
#
#  Version				2.1.1-beta1
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
SRC_INCLUDE=../nagios

CC=gcc
MOD_CFLAGS=-fPIC
CFLAGS=-g -O2 -DHAVE_CONFIG_H
MOD_LDFLAGS=-shared
LDFLAGS=
LIBS=

prefix=/usr/local/nagios
exec_prefix=${prefix}
INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o nagios -g nagios

DESTDIR=${prefix}/include

all:	modpd.o

modpd.o: modpd.c
	$(CC) -I $(SRC_INCLUDE) $(MOD_CFLAGS) $(CFLAGS) -o modpd.o modpd.c $(MOD_LDFLAGS) $(LDFLAGS) $(LIBS)

clean:
	rm -f modpd.o
	rm -f *~ *.*~

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DESTDIR)
	$(INSTALL) -s -m 774 $(INSTALL_OPTS) modpd.o $(DESTDIR)
