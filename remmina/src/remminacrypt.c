/*
 * Remmina - The GTK+ Remote Desktop Client
 * Copyright (C) 2009 - Vic Lee 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, 
 * Boston, MA 02111-1307, USA.
 */

#include "config.h"
#include <glib.h>
#ifdef HAVE_LIBGCRYPT
#include <gcrypt.h>
#endif
#include "remminapref.h"
#include "remminacrypt.h"

#ifdef HAVE_LIBGCRYPT
static gboolean
remmina_crypt_init (gcry_cipher_hd_t *phd)
{
    gcry_error_t err;
    guchar *secret;
    gsize secret_len;

    secret = g_base64_decode (remmina_pref.secret, &secret_len);
    if (secret_len < 32)
    {
        g_print ("secret corrupted\n");
        g_free (secret);
        return FALSE;
    }

    err = gcry_cipher_open (phd, GCRY_CIPHER_3DES, GCRY_CIPHER_MODE_CBC, 0);
    if (err)
    {
        g_print ("gcry_cipher_open failure: %s\n", gcry_strerror (err));
        g_free (secret);
        return FALSE;
    }

    err = gcry_cipher_setkey ((*phd), secret, 24);
    if (err)
    {
        g_print ("gcry_cipher_setkey failure: %s\n", gcry_strerror (err));
        g_free (secret);
        gcry_cipher_close ((*phd));
        return FALSE;
    }

    err = gcry_cipher_setiv ((*phd), secret + 24, 8);
    if (err)
    {
        g_print ("gcry_cipher_setiv failure: %s\n", gcry_strerror (err));
        g_free (secret);
        gcry_cipher_close ((*phd));
        return FALSE;
    }

    g_free (secret);

    return TRUE;
}

gchar*
remmina_crypt_encrypt (const gchar *str)
{
    gcry_error_t err;
    gcry_cipher_hd_t hd;
    guchar *buf;
    gint buf_len;
    gchar *result;

    if (!str || str[0] == '\0') return NULL;

    if (!remmina_crypt_init (&hd)) return NULL;

    buf_len = strlen (str);
    /* Pack to 64bit block size, and make sure it's always 0-terminated */
    buf_len += 8 - buf_len % 8;
    buf = (guchar*) g_malloc (buf_len);
    memset (buf, 0, buf_len);
    memcpy (buf, str, strlen (str));

    err = gcry_cipher_encrypt (hd, buf, buf_len, NULL, 0);
    if (err)
    {
        g_print ("gcry_cipher_encrypt failure: %s\n", gcry_strerror (err));
        g_free (buf);
        gcry_cipher_close (hd);
        return NULL;
    }

    result = g_base64_encode (buf, buf_len);

    g_free (buf);
    gcry_cipher_close (hd);

    return result;
}

gchar*
remmina_crypt_decrypt (const gchar *str)
{
    gcry_error_t err;
    gcry_cipher_hd_t hd;
    guchar *buf;
    gsize buf_len;

    if (!str || str[0] == '\0') return NULL;

    if (!remmina_crypt_init (&hd)) return NULL;

    buf = g_base64_decode (str, &buf_len);

    err = gcry_cipher_decrypt (hd, buf, buf_len, NULL, 0);
    if (err)
    {
        g_print ("gcry_cipher_decrypt failure: %s\n", gcry_strerror (err));
        g_free (buf);
        gcry_cipher_close (hd);
        return NULL;
    }

    gcry_cipher_close (hd);

    /* Just in case */
    buf[buf_len - 1] = '\0';

    return (gchar*) buf;
}

#else

gchar*
remmina_crypt_encrypt (const gchar *str)
{
    return NULL;
}

gchar*
remmina_crypt_decrypt (const gchar *str)
{
    return NULL;
}

#endif

