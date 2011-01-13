SUBDIRS = man
sbin_PROGRAMS = mkcomposecache

AM_CFLAGS = $(XLIB_CFLAGS) $(CWARNFLAGS)
mkcomposecache_SOURCES = mkcomposecache.c
mkcomposecache_LDADD = $(XLIB_LIBS)

EXTRA_DIST = mkallcomposecaches.sh
MAINTAINERCLEANFILES = ChangeLog INSTALL

.PHONY: ChangeLog INSTALL

INSTALL:
	$(INSTALL_CMD)

ChangeLog:
	$(CHANGELOG_CMD)

dist-hook: ChangeLog INSTALL
