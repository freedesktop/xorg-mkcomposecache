# -*- Autoconf -*-

AC_PREREQ(2.53)
AC_INIT([mkcomposecache], [1.0], [https://bugs.freedesktop.org/enter_bug.cgi?product=xorg])
AC_CONFIG_SRCDIR([mkcomposecache.c])

AM_INIT_AUTOMAKE([dist-bzip2])
AM_MAINTAINER_MODE


AC_PROG_CC
AC_PROG_INSTALL

PKG_CHECK_MODULES(XLIB, x11)

AC_CHECK_HEADERS([stdio.h stdlib.h string.h unistd.h locale.h], , [AC_MSG_FAILURE("cannot find essential header")])
AC_CHECK_FUNCS([setlocale], , [AC_MSG_FAILURE("cannot find essential function")])


AC_SUBST(XLIB_CFLAGS)
AC_SUBST(XLIB_LIBS)

AC_OUTPUT([Makefile doc/Makefile])
