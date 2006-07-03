/* Copyright 2005 SUSE Products GmbH
 * 
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation.
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <locale.h>

int main (int argc, char *argv[]) {
    Display *disp;
    XIM      im;
    char    *src, *dest;
    int      len;

    if (argc != 4 && argc != 5) {
	fprintf (stderr, "Usage: %s <Locale> <ComposeFile> <CacheDir> [<InternalName>]\n", argv[0]);
	return 1;
    }

    if (! setlocale (LC_ALL, argv[1])) {
	fprintf (stderr, "* locale %s not supported by libc.\n", argv[1]);
	return 2;
    }

    if (! XSupportsLocale ()) {
	fprintf (stderr, "* locale %s not supported by libX11.\n", argv[1]);
	return 2;
    }

    if (! getuid()) {
	fprintf (stderr, "* libX11 will *not* create any cache files for root.\n");
	return 1;
    }

    src  = malloc (strlen (argv[2]) + 14);
    len  = strlen (argv[3]) + 15;
    if (argc == 5)
	len += strlen (argv[4]) + 1;
    dest = malloc (len);
    if (! src || ! dest) {
	perror ("* malloc");
	return 1;
    }
    sprintf (src,  "XCOMPOSEFILE=%s", argv[2]);
    if (argc == 4)
        sprintf (dest, "XCOMPOSECACHE=%s", argv[3]);
    else
        sprintf (dest, "XCOMPOSECACHE=%s=%s", argv[3], argv[4]);
    putenv  (src);
    putenv  (dest);

    if (! (disp = XOpenDisplay (NULL)) ) {
	perror ("* XOpenDisplay");
	return 1;
    }
    XSetLocaleModifiers("");
    im = XOpenIM  (disp, NULL, NULL, NULL);

    if (im)
	XCloseIM      (im);
    XCloseDisplay (disp);

    return 0;
}
