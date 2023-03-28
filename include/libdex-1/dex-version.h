/* dex-version.h.in
 *
 * Copyright 2022 Christian Hergert
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#if !defined(DEX_INSIDE) && !defined(DEX_COMPILATION)
# error "Only <libdex.h> can be included directly."
#endif

/**
 * SECTION:libdexversion
 * @short_description: libdex version checking
 *
 * libdex provides macros to check the version of the library
 * at compile-time
 */

/**
 * DEX_MAJOR_VERSION:
 *
 * libdex major version component (e.g. 1 if %DEX_VERSION is 1.2.3)
 */
#define DEX_MAJOR_VERSION (0)

/**
 * DEX_MINOR_VERSION:
 *
 * libdex minor version component (e.g. 2 if %DEX_VERSION is 1.2.3)
 */
#define DEX_MINOR_VERSION (2)

/**
 * DEX_MICRO_VERSION:
 *
 * libdex micro version component (e.g. 3 if %DEX_VERSION is 1.2.3)
 */
#define DEX_MICRO_VERSION (1)

/**
 * DEX_VERSION
 *
 * libdex version.
 */
#define DEX_VERSION (0.2.1)

/**
 * DEX_VERSION_S:
 *
 * libdex version, encoded as a string, useful for printing and
 * concatenation.
 */
#define DEX_VERSION_S "0.2.1"

#define DEX_ENCODE_VERSION(major,minor,micro) \
        ((major) << 24 | (minor) << 16 | (micro) << 8)

/**
 * DEX_VERSION_HEX:
 *
 * libdex version, encoded as an hexadecimal number, useful for
 * integer comparisons.
 */
#define DEX_VERSION_HEX \
        (DEX_ENCODE_VERSION (DEX_MAJOR_VERSION, DEX_MINOR_VERSION, DEX_MICRO_VERSION))

/**
 * DEX_CHECK_VERSION:
 * @major: required major version
 * @minor: required minor version
 * @micro: required micro version
 *
 * Compile-time version checking. Evaluates to %TRUE if the version
 * of libdex is greater than the required one.
 */
#define DEX_CHECK_VERSION(major,minor,micro)   \
        (DEX_MAJOR_VERSION > (major) || \
         (DEX_MAJOR_VERSION == (major) && DEX_MINOR_VERSION > (minor)) || \
         (DEX_MAJOR_VERSION == (major) && DEX_MINOR_VERSION == (minor) && \
          DEX_MICRO_VERSION >= (micro)))
