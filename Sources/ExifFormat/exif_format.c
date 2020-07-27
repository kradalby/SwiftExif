//
//  exif_format.c
//  SwiftExif
//
//  This file borrows a "private" function from libexif.
//  All rights belong to the original author
//

#include <libexif/exif-entry.h>
#include <libexif/exif-ifd.h>
#include <libexif/exif-utils.h>

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "exif_format.h"

/*! Format the value of an ExifEntry for human display in a generic way.
 * The output is localized. The formatting is independent of the tag number
 * and is based entirely on the data type.
 * \pre The ExifEntry is already a member of an ExifData.
 * \param[in] e EXIF entry
 * \param[out] val buffer in which to store value
 * \param[in] maxlen the length of the buffer val
 */
void exif_entry_format_value(ExifEntry *e, char *val, size_t maxlen)
{
    ExifByte v_byte;
    ExifShort v_short;
    ExifSShort v_sshort;
    ExifLong v_long;
    ExifRational v_rat;
    ExifSRational v_srat;
    ExifSLong v_slong;
    unsigned int i;
    size_t len;
    const ExifByteOrder o = exif_data_get_byte_order(e->parent->parent);

    if (!e->size || !maxlen)
        return;
    switch (e->format)
    {
    case EXIF_FORMAT_UNDEFINED:
        snprintf(val, maxlen, _("%i bytes undefined data"), e->size);
        break;
    case EXIF_FORMAT_BYTE:
    case EXIF_FORMAT_SBYTE:
        v_byte = e->data[0];
        snprintf(val, maxlen, "0x%02x", v_byte);
        len = strlen(val);
        for (i = 1; i < e->components; i++)
        {
            v_byte = e->data[i];
            snprintf(val + len, maxlen - len, ", 0x%02x", v_byte);
            len += strlen(val + len);
            if (len >= maxlen - 1)
                break;
        }
        break;
    case EXIF_FORMAT_SHORT:
        v_short = exif_get_short(e->data, o);
        snprintf(val, maxlen, "%u", v_short);
        len = strlen(val);
        for (i = 1; i < e->components; i++)
        {
            v_short = exif_get_short(e->data +
                                         exif_format_get_size(e->format) * i,
                                     o);
            snprintf(val + len, maxlen - len, ", %u", v_short);
            len += strlen(val + len);
            if (len >= maxlen - 1)
                break;
        }
        break;
    case EXIF_FORMAT_SSHORT:
        v_sshort = exif_get_sshort(e->data, o);
        snprintf(val, maxlen, "%i", v_sshort);
        len = strlen(val);
        for (i = 1; i < e->components; i++)
        {
            v_sshort = exif_get_short(e->data +
                                          exif_format_get_size(e->format) *
                                              i,
                                      o);
            snprintf(val + len, maxlen - len, ", %i", v_sshort);
            len += strlen(val + len);
            if (len >= maxlen - 1)
                break;
        }
        break;
    case EXIF_FORMAT_LONG:
        v_long = exif_get_long(e->data, o);
        snprintf(val, maxlen, "%lu", (unsigned long)v_long);
        len = strlen(val);
        for (i = 1; i < e->components; i++)
        {
            v_long = exif_get_long(e->data +
                                       exif_format_get_size(e->format) *
                                           i,
                                   o);
            snprintf(val + len, maxlen - len, ", %lu", (unsigned long)v_long);
            len += strlen(val + len);
            if (len >= maxlen - 1)
                break;
        }
        break;
    case EXIF_FORMAT_SLONG:
        v_slong = exif_get_slong(e->data, o);
        snprintf(val, maxlen, "%li", (long)v_slong);
        len = strlen(val);
        for (i = 1; i < e->components; i++)
        {
            v_slong = exif_get_slong(e->data +
                                         exif_format_get_size(e->format) * i,
                                     o);
            snprintf(val + len, maxlen - len, ", %li", (long)v_slong);
            len += strlen(val + len);
            if (len >= maxlen - 1)
                break;
        }
        break;
    case EXIF_FORMAT_ASCII:
        strncpy(val, (char *)e->data, MIN(maxlen - 1, e->size));
        val[MIN(maxlen - 1, e->size)] = 0;
        break;
    case EXIF_FORMAT_RATIONAL:
        len = 0;
        for (i = 0; i < e->components; i++)
        {
            if (i > 0)
            {
                snprintf(val + len, maxlen - len, ", ");
                len += strlen(val + len);
            }
            v_rat = exif_get_rational(
                e->data + 8 * i, o);
            if (v_rat.denominator)
            {
                /*
                 * Choose the number of significant digits to
                 * display based on the size of the denominator.
                 * It is scaled so that denominators within the
                 * range 13..120 will show 2 decimal points.
                 */
                int decimals = (int)(log10(v_rat.denominator) - 0.08 + 1.0);
                snprintf(val + len, maxlen - len, "%2.*f",
                         decimals,
                         (double)v_rat.numerator /
                             (double)v_rat.denominator);
            }
            else
                snprintf(val + len, maxlen - len, "%lu/%lu",
                         (unsigned long)v_rat.numerator,
                         (unsigned long)v_rat.denominator);
            len += strlen(val + len);
            if (len >= maxlen - 1)
                break;
        }
        break;
    case EXIF_FORMAT_SRATIONAL:
        len = 0;
        for (i = 0; i < e->components; i++)
        {
            if (i > 0)
            {
                snprintf(val + len, maxlen - len, ", ");
                len += strlen(val + len);
            }
            v_srat = exif_get_srational(
                e->data + 8 * i, o);
            if (v_srat.denominator)
            {
                int decimals = (int)(log10(abs(v_srat.denominator)) - 0.08 + 1.0);
                snprintf(val + len, maxlen - len, "%2.*f",
                         decimals,
                         (double)v_srat.numerator /
                             (double)v_srat.denominator);
            }
            else
                snprintf(val + len, maxlen - len, "%li/%li",
                         (long)v_srat.numerator,
                         (long)v_srat.denominator);
            len += strlen(val + len);
            if (len >= maxlen - 1)
                break;
        }
        break;
    case EXIF_FORMAT_DOUBLE:
    case EXIF_FORMAT_FLOAT:
    default:
        snprintf(val, maxlen, _("%i bytes unsupported data type"),
                 e->size);
        break;
    }
}
