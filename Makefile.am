SUBDIRS = doc

AM_CFLAGS = @XLIB_CFLAGS@ -Wall

sbin_PROGRAMS = mkcomposecache
EXTRA_DIST = mkallcomposecaches.sh

mkcomposecache_SOURCES = mkcomposecache.c

mkcomposecache_LDADD = @XLIB_LIBS@

MAINTAINERCLEANFILES = Makefile.in configure aclocal.m4 depcomp install-sh missing
