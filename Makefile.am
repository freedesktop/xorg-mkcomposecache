AM_CFLAGS = @XLIB_CFLAGS@ $(CWARNFLAGS)

sbin_PROGRAMS = mkcomposecache

adminmandir = $(ADMIN_MAN_DIR)
adminman_PRE = mkcomposecache.man
adminman_DATA = $(adminman_PRE:man=@ADMIN_MAN_SUFFIX@)

EXTRA_DIST = ChangeLog mkallcomposecaches.sh $(adminman_PRE)

mkcomposecache_SOURCES = mkcomposecache.c

mkcomposecache_LDADD = @XLIB_LIBS@

CLEANFILES = $(adminman_DATA)
MAINTAINERCLEANFILES = Makefile.in configure aclocal.m4 config.h.in depcomp install-sh missing ChangeLog

.PHONY: ChangeLog
ChangeLog:
	$(CHANGELOG_CMD)

dist-hook: ChangeLog

SED = sed

# Strings to replace in man pages
XORGRELSTRING = @PACKAGE_STRING@
  XORGMANNAME = X Version 11

MAN_SUBSTS = \
	-e 's|__xorgversion__|"$(XORGRELSTRING)" "$(XORGMANNAME)"|' \
	-e 's|__projectroot__|$(prefix)|g' \
	-e 's|__apploaddir__|$(appdefaultdir)|' \
	-e 's|__adminmansuffix__|$(ADMIN_MAN_SUFFIX)|g' \
	-e 's|__libmansuffix__|$(LIB_MAN_SUFFIX)|g' \
	-e 's|__adminmansuffix__|$(ADMIN_MAN_SUFFIX)|g' \
	-e 's|__miscmansuffix__|$(MISC_MAN_SUFFIX)|g' \
	-e 's|__filemansuffix__|$(FILE_MAN_SUFFIX)|g'

SUFFIXES = .$(ADMIN_MAN_SUFFIX) .man

.man.$(ADMIN_MAN_SUFFIX):
	$(AM_V_GEN)$(SED) $(MAN_SUBSTS) < $< > $@
