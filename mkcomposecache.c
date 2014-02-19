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

#include "config.h"

#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <locale.h>

#ifndef HAVE_ASPRINTF
#include <stdarg.h>

/* sprintf variant found in newer libc's which allocates string to print to */
static int _X_ATTRIBUTE_PRINTF(2,3)
asprintf(char ** ret, const char *format, ...)
{
    char buf[256];
    int len;
    va_list ap;

    va_start(ap, format);
    len = vsnprintf(buf, sizeof(buf), format, ap);
    va_end(ap);

    if (len < 0)
	return -1;

    if (len < sizeof(buf))
    {
	*ret = strdup(buf);
    }
    else
    {
	*ret = malloc(len + 1); /* vsnprintf doesn't count trailing '\0' */
	if (*ret != NULL)
	{
	    va_start(ap, format);
	    len = vsnprintf(*ret, len + 1, format, ap);
	    va_end(ap);
	    if (len < 0) {
		free(*ret);
		*ret = NULL;
	    }
	}
    }

    if (*ret == NULL)
	return -1;

    return len;
}
#endif /* HAVE_ASPRINTF */

int main (int argc, char *argv[]) {
    Display *disp;
    XIM      im;
    char    *src, *dest;
    int      ret;

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

    if (asprintf (&src, "XCOMPOSEFILE=%s", argv[2]) == -1) {
	perror ("* asprintf");
	return 1;
    }

    if (argc == 4)
	ret = asprintf (&dest, "XCOMPOSECACHE=%s", argv[3]);
    else
	ret = asprintf (&dest, "XCOMPOSECACHE=%s=%s", argv[3], argv[4]);
    if (ret == -1) {
	perror ("* asprintf");
	return 1;
    }

    putenv  (src);
    putenv  (dest);
#if HAVE_UNSETENV
    unsetenv ("XMODIFIERS");
#else
    putenv ("XMODIFIERS");
#endif

    if (! (disp = XOpenDisplay (NULL)) ) {
	perror ("* XOpenDisplay");
	return 1;
    }
    XSetLocaleModifiers("");
    if (! (im = XOpenIM  (disp, NULL, NULL, NULL)) )
	fputs ("* XOpenIM: no input method\n", stderr);

    if (im)
	XCloseIM      (im);
    XCloseDisplay (disp);

    return 0;
}
