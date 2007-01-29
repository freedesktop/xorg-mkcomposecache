SUBDIRS = doc

AM_CFLAGS = @XLIB_CFLAGS@ -Wall

sbin_PROGRAMS = mkcomposecache
EXTRA_DIST = ChangeLog mkallcomposecaches.sh

mkcomposecache_SOURCES = mkcomposecache.c

mkcomposecache_LDADD = @XLIB_LIBS@

CLEANFILES=ChangeLog
MAINTAINERCLEANFILES = Makefile.in configure aclocal.m4 config.h.in depcomp install-sh missing ChangeLog

.PHONY: ChangeLog
ChangeLog:
	(GIT_DIR=$(top_srcdir)/.git git-log > .changelog.tmp && mv .changelog.tmp ChangeLog; rm -f .changelog.tmp) || (touch ChangeLog; echo 'git directory not found: installing possibly empty changelog.' >&2)

dist-hook: ChangeLog

