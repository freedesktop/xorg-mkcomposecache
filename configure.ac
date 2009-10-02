# -*- Autoconf -*-

AC_PREREQ(2.53)
AC_INIT([mkcomposecache], [1.2.1], [https://bugs.freedesktop.org/enter_bug.cgi?product=xorg])
AC_CONFIG_SRCDIR([mkcomposecache.c])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([dist-bzip2])
AM_MAINTAINER_MODE

# Require xorg-macros 1.3 for XORG_DEFAULT_OPTIONS
m4_ifndef([XORG_MACROS_VERSION], [AC_FATAL([must install xorg-macros 1.3 or later before running autoconf/autogen])])
XORG_MACROS_VERSION(1.3)

AC_PROG_CC
XORG_DEFAULT_OPTIONS
AC_PROG_INSTALL

PKG_CHECK_MODULES(XLIB, x11)

AC_CHECK_HEADERS([stdio.h stdlib.h string.h unistd.h locale.h], , [AC_MSG_FAILURE("cannot find essential header")])
AC_CHECK_FUNCS([setlocale], , [AC_MSG_FAILURE("cannot find essential function")])
AC_CHECK_FUNCS([unsetenv])

AC_SUBST(XLIB_CFLAGS)
AC_SUBST(XLIB_LIBS)

AC_OUTPUT([Makefile])
