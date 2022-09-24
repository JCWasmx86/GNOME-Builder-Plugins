/* tmpl-version.h.in
 *
 * Copyright (C) 2015-2017 Christian Hergert <chergert@redhat.com>
 *
 * This file is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TMPL_VERSION_H
#define TMPL_VERSION_H

#if !defined(TMPL_GLIB_INSIDE) && !defined(TMPL_GLIB_COMPILATION)
#error "Only <tmpl-glib.h> can be included directly."
#endif

/**
 * TMPL_MAJOR_VERSION:
 *
 * Template-GLibl major version component (e.g. 1 if %TMPL_VERSION is 1.2.3)
 */
#define TMPL_MAJOR_VERSION              (3)

/**
 * TMPL_MINOR_VERSION:
 *
 * Template-GLibl minor version component (e.g. 2 if %TMPL_VERSION is 1.2.3)
 */
#define TMPL_MINOR_VERSION              (36)

/**
 * TMPL_MICRO_VERSION:
 *
 * Template-GLibl micro version component (e.g. 3 if %TMPL_VERSION is 1.2.3)
 */
#define TMPL_MICRO_VERSION              (1)

/**
 * TMPL_VERSION
 *
 * Template-GLibl version.
 */
#define TMPL_VERSION                    (3.36.1)

/**
 * TMPL_VERSION_S:
 *
 * Template-GLib version, encoded as a string, useful for printing and
 * concatenation.
 */
#define TMPL_VERSION_S                  "3.36.1"

#define TMPL_ENCODE_VERSION(major,minor,micro) \
        ((major) << 24 | (minor) << 16 | (micro) << 8)

/**
 * TMPL_VERSION_HEX:
 *
 * Template-GLib version, encoded as an hexadecimal number, useful for
 * integer comparisons.
 */
#define TMPL_VERSION_HEX \
        (TMPL_ENCODE_VERSION (TMPL_MAJOR_VERSION, TMPL_MINOR_VERSION, TMPL_MICRO_VERSION))

/**
 * TMPL_CHECK_VERSION:
 * @major: required major version
 * @minor: required minor version
 * @micro: required micro version
 *
 * Compile-time version checking. Evaluates to %TRUE if the version
 * of template-glib is greater than the required one.
 */
#define TMPL_CHECK_VERSION(major,minor,micro)   \
        (TMPL_MAJOR_VERSION > (major) || \
         (TMPL_MAJOR_VERSION == (major) && TMPL_MINOR_VERSION > (minor)) || \
         (TMPL_MAJOR_VERSION == (major) && TMPL_MINOR_VERSION == (minor) && \
          TMPL_MICRO_VERSION >= (micro)))

#endif /* TMPL_VERSION_H */
