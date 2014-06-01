# -*- Autoconf -*-

AC_PREREQ([2.60])
AC_INIT([mkcomposecache], [1.2.1], [https://bugs.freedesktop.org/enter_bug.cgi?product=xorg])
AC_CONFIG_SRCDIR([mkcomposecache.c])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([foreign dist-bzip2])

# Set common system defines for POSIX extensions, such as _GNU_SOURCE
# Must be called before any macros that run the compiler (like those in
# XORG_DEFAULT_OPTIONS) to avoid autoconf errors.
AC_USE_SYSTEM_EXTENSIONS

# Require X.Org macros 1.8 or later for MAN_SUBSTS set by XORG_MANPAGE_SECTIONS
m4_ifndef([XORG_MACROS_VERSION],
          [m4_fatal([must install xorg-macros 1.8 or later before running autoconf/autogen])])
XORG_MACROS_VERSION(1.8)
XORG_DEFAULT_OPTIONS

PKG_CHECK_MODULES(XLIB, x11)

AC_CHECK_HEADERS([stdio.h stdlib.h string.h unistd.h locale.h], , [AC_MSG_FAILURE("cannot find essential header")])
AC_CHECK_FUNCS([setlocale], , [AC_MSG_FAILURE("cannot find essential function")])
AC_CHECK_FUNCS([unsetenv asprintf])

AC_CONFIG_FILES([
	Makefile
	man/Makefile])
AC_OUTPUT
