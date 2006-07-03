#!/bin/sh

# Create compose caches for all known locales
# Designed to run in a DESTDIR install environment


exiterr() {
  echo 1>&2 "$1"
  exit 1
}

usage() {
  echo 2>&1 "$0 [x11-root] [/prefix]"
  echo 2>&1 "e.g. $0 /tmp/build-xorg /usr/X11R6"
  exit 1
}

[ $# != 2 ] && usage
case "$1" in
-*)
  usage
esac

ROOT="$1"
PREFIX="`echo "$2" | sed 's|^//*||;s|^|/|;s|/*/$||'`"

xvfb=$PREFIX/bin/Xvfb
mkcomposecache=$PREFIX/sbin/mkcomposecache
localedir=$PREFIX/lib/X11/locale
test -r $ROOT$PREFIX/share/X11/locale/compose.dir && localedir=$PREFIX/share/X11/locale
composecache=/var/X11R6/compose-cache

test -d $ROOT                       || exiterr "no directory $ROOT"
test -x $ROOT$xvfb                  || exiterr "cannot find $xvfb in $ROOT"
test -x $ROOT$PREFIX/bin/xbiff      || exiterr "cannot find $PREFIX/bin/xbiff in $ROOT"
test -x $ROOT$mkcomposecache        || exiterr "cannot find $mkcomposecache in $ROOT"
test -r $ROOT$localedir/compose.dir || exiterr "cannot find $localedir in $ROOT"

mkdir -p $ROOT$composecache
chmod 755 $ROOT$composecache

tmpfile="`mktemp /tmp/Xvfb.log.XXXXXXXXXX`"
tmpdir="`mktemp -d /tmp/mkcomposecache.XXXXXXXXXX`"

echo "Creating compose cache files in $ROOT$composecache/"
echo "  for $ROOT$localedir/*, internal name $localedir/*"
echo ""
echo "Starting Xvfb..."
$ROOT$xvfb \
  -fp $ROOT$PREFIX/lib/X11/fonts/misc/ \
  -sp $ROOT/etc/X11/xserver/SecurityPolicy \
  -co $ROOT$PREFIX/lib/X11/rgb \
  :99 &> $tmpfile &
trap "echo 1>&2 'Killing Xvfb...'; kill $! 2>/dev/null; rm -rf $tmpdir 2>/dev/null; rm -f $tmpfile 2>/dev/null; true" 0

DISPLAY=:99
LD_LIBRARY_PATH=$ROOT$PREFIX/lib64:$ROOT$PREFIX/lib
XLOCALEDIR=$ROOT$localedir/
export DISPLAY LD_LIBRARY_PATH XLOCALEDIR

sleep 5
$ROOT$PREFIX/bin/xbiff 1>/dev/null 2>&1 &
echo ""

while read comp loc ; do
  if [ -r "$ROOT$localedir/$comp" ] ; then
    rm -f $tmpdir/*
    $ROOT$mkcomposecache "$loc" "$ROOT$localedir/$comp" $tmpdir "$localedir/$comp"
    case $? in
    0)
      f="`/bin/ls $tmpdir`"
      if [ -r "$tmpdir/$f" ] ; then
        if [ -r $ROOT$composecache/$f ] ; then
	  if cmp $tmpdir/$f $ROOT$composecache/$f ; then
	    echo "verified cache for $loc ($comp): $f"
	  else
            mv $ROOT$composecache/$f $ROOT$composecache/$f.old
            mv $tmpdir/$f $ROOT$composecache/
	    echo 1>&2 "* WARNING:"
	    echo 1>&2 "  invalid (old?) cache for $loc ($comp): $f.old"
	  fi
	else
          mv $tmpdir/$f $ROOT$composecache/
          echo "created  cache for $loc ($comp): $f"
	fi
      else
	echo 1>&2 "* WARNING:"
        echo 1>&2 "  mkcomposecache did not create any cache for $loc ($comp)"
      fi
      ;;
    1)
      echo 1>&2 "* WARNING:"
      echo 1>&2 "  mkcomposecache failed for $loc ($comp)"
      ;;
    2)
      # error 'locale not supported' already printed by mkcomposecache
      ;;
    esac
  fi
done < $ROOT$localedir/compose.dir

exit 0

#EOF
