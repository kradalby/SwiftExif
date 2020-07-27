//
//  exif_format.h
//  SwiftExif
//
//  Created by Kristoffer Dalby on 19/07/2020.
//

#ifndef exif_format_h
#define exif_format_h

#include <libexif/exif-entry.h>
#include <libexif/exif-ifd.h>
#include <libexif/exif-utils.h>

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

void exif_entry_format_value(ExifEntry *e, char *val, size_t maxlen);

#endif /* exif_format_h */
