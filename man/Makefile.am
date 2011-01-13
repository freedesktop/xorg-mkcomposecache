
adminmandir = $(ADMIN_MAN_DIR)
adminman_PRE = mkcomposecache.man
adminman_DATA = $(adminman_PRE:man=@ADMIN_MAN_SUFFIX@)

EXTRA_DIST = $(adminman_PRE)
CLEANFILES = $(adminman_DATA)
SUFFIXES = .$(ADMIN_MAN_SUFFIX) .man

# String replacements in MAN_SUBSTS now come from xorg-macros.m4 via configure
.man.$(ADMIN_MAN_SUFFIX):
	$(AM_V_GEN)$(SED) $(MAN_SUBSTS) < $< > $@
