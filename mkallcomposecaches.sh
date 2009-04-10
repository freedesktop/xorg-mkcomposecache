#!/bin/sh

# Create compose caches for all known locales
# Designed to run in a DESTDIR install environment


exiterr() {
  echo 1>&2 "$1"
  exit 1
}

usage() {
cat 1>&2 <<EOUSAGE

$0 [var=arg] [...] root
  e.g. $0 prefix=/usr/X11R7 /tmp/build-xorg
Double quote args with spaces.
  e.g. $0 "xvfbopts='-fp catalogue:/etc/X11/fontpath.d'" /tmp/build-xorg

Base defaults:
    prefix=/usr
    libs={lib64,lib}
    user=nobody  (only if $0 is run as root)

Program + args defaults:
    xvfb=\$root\$prefix/bin/Xvfb
    xvfbopts='-fp \$root\$prefix/\$libs/X11/fonts/misc/,
                  \$root\$prefix/share/fonts/misc'
    xbiff=\$root\$prefix/bin/xbiff
    mkcomposecache=\$root\$prefix/sbin/mkcomposecache

Directory + path defaults:
    ldpath='\$root\$prefix/\$libs'
    cachedir=\$root/var/cache/libx11/compose
    localedir=\$prefix/{share,\$libs}/X11/locale  (relative to \$root)

EOUSAGE
  exit 1
}


# Option parsing

while [ "x$1" != x ] ; do
  case "$1" in
  -*)
    usage
    ;;
  *=*)
    eval "$1"
    shift
    ;;
  *)
    break
  esac
done

test $# == 1 || usage


# Defaults

root="$1"
test "x$prefix" = x  && prefix=/usr
root="`echo "$root"     | sed 's|^//*||;s|^|/|;s|/*/$||'`"
prefix="`echo "$prefix" | sed 's|^//*||;s|^|/|;s|/*/$||'`"

if [ "x$libs" = x ] ; then
  test -d $root$prefix/lib   && libs=lib
  test -d $root$prefix/lib64 && libs=lib64
fi
if [ "x$localedir" = x ] ; then
  test -r $root$prefix/$libs/X11/locale/compose.dir && localedir=$prefix/$libs/X11/locale
  test -r $root$prefix/share/X11/locale/compose.dir && localedir=$prefix/share/X11/locale
fi

test "x$ldpath" = x         && ldpath=$root$prefix/$libs
test "x$xvfb" = x           && xvfb=$root$prefix/bin/Xvfb
test "x$xbiff" = x          && xbiff=$root$prefix/bin/xbiff
test "x$mkcomposecache" = x && mkcomposecache=$root$prefix/sbin/mkcomposecache
test "x$cachedir" = x       && cachedir=$root/var/cache/libx11/compose
test "x$xvfbopts" = x       && xvfbopts="-fp $root$prefix/$libs/X11/fonts/misc/,$root$prefix/share/fonts/misc"
test "x$user" = x           && user=nobody
test "x`whoami`" = xroot    || user=""

# Verification

test -d $root                       || exiterr "no directory $root"
test -d $root$prefix                || exiterr "no directory $prefix in $root"

test "x$libs" = x                   && exiterr "no default libs found"
test "x$localedir" = x              && exiterr "no default localedir found"

test -x $xvfb                       || exiterr "cannot find $xvfb"
test -x $xbiff                      || exiterr "cannot find $xbiff"
test -x $mkcomposecache             || exiterr "cannot find $mkcomposecache"
test -r $root$localedir/compose.dir || exiterr "cannot find $root$localedir"

cat <<EOSETUP

Creating compose cache files in $cachedir/
for $root$localedir/*, internal name $localedir/*

  root           ${root:-/}
  prefix         ${prefix:-/}
  libs           $libs
  user           ${user:--}

  xvfb           $xvfb
  xvfbopts       $xvfbopts
  xbiff          $xbiff
  mkcomposecache $mkcomposecache

  ldpath         $ldpath
  cachedir       $cachedir
  localedir      $localedir  in ${root:-/}

EOSETUP


# Setup

mkdir -p $cachedir  || exiterr "cannot mkdir $cachedir"
chmod 755 $cachedir || exiterr "cannot chmod $cachedir"

tmpfile="`mktemp /tmp/Xvfb.log.XXXXXXXXXX`"
tmpdir="`mktemp -d /tmp/mkcomposecache.XXXXXXXXXX`"

if [ "x$user" != x ] ; then
  chown ${user}:root $tmpdir || exiterr "cannot chown $cachedir to ${user}:root"
fi

echo "Starting Xvfb..."
$xvfb $xvfbopts :99  1>$tmpfile 2>&1  &
trap "echo 1>&2 'Killing Xvfb...'; kill $! 2>/dev/null; sleep 1; echo 1>&2 'Xvfb output:'; cat 1>&2 $tmpfile; rm -rf $tmpdir 2>/dev/null; rm -f $tmpfile 2>/dev/null; true" 0

DISPLAY=:99
LD_LIBRARY_PATH="$ldpath"
XLOCALEDIR=$root$localedir
export DISPLAY LD_LIBRARY_PATH XLOCALEDIR

# Starting a single program so that x does not re-initialize for each mkcomposecache
sleep 5
$xbiff 2>&1 &
echo ""


# Create caches

while read comp loc ; do
  if [ -r "$root$localedir/$comp" ] ; then
    rm -f $tmpdir/*
    if [ "x$user" = x ] ; then
      $mkcomposecache "$loc" "$root$localedir/$comp" $tmpdir "$localedir/$comp"
    else
      su -c "$mkcomposecache '$loc' '$root$localedir/$comp' $tmpdir '$localedir/$comp'" $user
    fi
    case $? in
    0)
      f="`/bin/ls $tmpdir`"
      if [ -f "$tmpdir/$f" -a -r "$tmpdir/$f" ] ; then
        if [ -r $cachedir/$f ] ; then
	  if cmp $tmpdir/$f $cachedir/$f ; then
	    echo "verified cache for $loc ($comp): $f"
	  else
            mv $cachedir/$f $cachedir/$f.old
            mv $tmpdir/$f $cachedir/
	    echo 1>&2 "* WARNING:"
	    echo 1>&2 "  invalid (old?) cache for $loc ($comp): $f.old"
	  fi
	else
          mv $tmpdir/$f $cachedir/
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
done < $root$localedir/compose.dir


# Aftermaths

find $cachedir -type f | xargs chmod 444 || exiterr "cannot chmod $cachedir/*"
if [ "x$user" != x ] ; then
  chown -R root:root $cachedir || exiterr "cannot chown $cachedir to root:root"
else
  echo ""
  echo "NOTE:"
  echo "  The files in $cachedir are currently owned by `whoami`."
  echo "  They have to be owned by root in the final installation in order to work."
  echo ""
fi

echo "Success."

exit 0

#EOF
