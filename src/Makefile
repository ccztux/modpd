###################################
# Makefile for NEB module modpd
#
# Last Modified: 2020-01-30
###################################


# Source code directories
SRC_INCLUDE=../nagios

CC=gcc
MOD_CFLAGS=-fPIC
CFLAGS=-g -O2 -DHAVE_CONFIG_H
MOD_LDFLAGS=-shared
LDFLAGS=
LIBS=

prefix=/usr/local/nagios
exec_prefix=${prefix}
BINDIR=${exec_prefix}/bin
INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o nagios -g nagios
COMMAND_OPTS=-o nagios -g nagcmd
STRIP=/usr/bin/strip

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
