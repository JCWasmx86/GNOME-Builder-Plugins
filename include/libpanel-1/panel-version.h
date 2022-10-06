/* panel-version.h.in
 *
 * Copyright 2021 Christian Hergert <chergert@redhat.com>
 *
 * This file is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 3 of the License, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

#pragma once

#if !defined(LIBPANEL_INSIDE) && !defined(LIBPANEL_COMPILATION)
# error "Only <libpanel.h> can be included directly."
#endif

/**
 * SECTION:panel-version
 * @title: Version Checking
 * @short_description: Conditionally include code based on libpanel version
 *
 * This module provides various macros that may be used to build code based
 * on the version of libpanel at build time.
 */

/**
 * PANEL_MAJOR_VERSION:
 *
 * libpanel major version component (e.g. 1 if %PANEL_VERSION is 1.2.3)
 */
#define PANEL_MAJOR_VERSION (1)

/**
 * PANEL_MINOR_VERSION:
 *
 * libpanel minor version component (e.g. 2 if %PANEL_VERSION is 1.2.3)
 */
#define PANEL_MINOR_VERSION (1)

/**
 * PANEL_MICRO_VERSION:
 *
 * libpanel micro version component (e.g. 3 if %PANEL_VERSION is 1.2.3)
 */
#define PANEL_MICRO_VERSION (0)

/**
 * PANEL_VERSION
 *
 * libpanel version.
 */
#define PANEL_VERSION (1.1.0)

/**
 * PANEL_VERSION_S:
 *
 * libpanel version, encoded as a string, useful for printing and
 * concatenation.
 */
#define PANEL_VERSION_S "1.1.0"

#define PANEL_ENCODE_VERSION(major,minor,micro) \
        ((major) << 24 | (minor) << 16 | (micro) << 8)

/**
 * PANEL_VERSION_HEX:
 *
 * libpanel version, encoded as an hexadecimal number, useful for
 * integer comparisons.
 */
#define PANEL_VERSION_HEX \
        (PANEL_ENCODE_VERSION (PANEL_MAJOR_VERSION, PANEL_MINOR_VERSION, PANEL_MICRO_VERSION))

/**
 * PANEL_CHECK_VERSION:
 * @major: required major version
 * @minor: required minor version
 * @micro: required micro version
 *
 * Compile-time version checking. Evaluates to %TRUE if the version
 * of libpanel is greater than the required one.
 */
#define PANEL_CHECK_VERSION(major,minor,micro)   \
        (PANEL_MAJOR_VERSION > (major) || \
         (PANEL_MAJOR_VERSION == (major) && PANEL_MINOR_VERSION > (minor)) || \
         (PANEL_MAJOR_VERSION == (major) && PANEL_MINOR_VERSION == (minor) && \
          PANEL_MICRO_VERSION >= (micro)))
