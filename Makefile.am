SUBDIRS = doc

AM_CFLAGS = @XLIB_CFLAGS@ $(CWARNFLAGS)

sbin_PROGRAMS = mkcomposecache
EXTRA_DIST = ChangeLog mkallcomposecaches.sh

mkcomposecache_SOURCES = mkcomposecache.c

mkcomposecache_LDADD = @XLIB_LIBS@

CLEANFILES=ChangeLog
MAINTAINERCLEANFILES = Makefile.in configure aclocal.m4 config.h.in depcomp install-sh missing ChangeLog

.PHONY: ChangeLog
ChangeLog:
	$(CHANGELOG_CMD)

dist-hook: ChangeLog

