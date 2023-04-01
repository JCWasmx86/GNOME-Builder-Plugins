/* tmpl-version-macros.h
 *
 * Copyright (C) 2017 Christian Hergert <chergert@redhat.com>
 *
 * This file is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
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

#ifndef TMPL_VERSION_MACROS_H
#define TMPL_VERSION_MACROS_H

#if !defined(TMPL_GLIB_INSIDE) && !defined(TMPL_GLIB_COMPILATION)
# error "Only <tmpl-glib.h> can be included directly."
#endif

#include <glib.h>

#include "tmpl-version.h"

#ifndef _TMPL_EXTERN
#define _TMPL_EXTERN extern
#endif

#ifdef TMPL_DISABLE_DEPRECATION_WARNINGS
#define TMPL_DEPRECATED _TMPL_EXTERN
#define TMPL_DEPRECATED_FOR(f) _TMPL_EXTERN
#define TMPL_UNAVAILABLE(maj,min) _TMPL_EXTERN
#else
#define TMPL_DEPRECATED G_DEPRECATED _TMPL_EXTERN
#define TMPL_DEPRECATED_FOR(f) G_DEPRECATED_FOR(f) _TMPL_EXTERN
#define TMPL_UNAVAILABLE(maj,min) G_UNAVAILABLE(maj,min) _TMPL_EXTERN
#endif

#define TMPL_VERSION_3_28 (G_ENCODE_VERSION (3, 28))
#define TMPL_VERSION_3_36 (G_ENCODE_VERSION (3, 36))

#if (TMPL_MINOR_VERSION == 99)
# define TMPL_VERSION_CUR_STABLE (G_ENCODE_VERSION (TMPL_MAJOR_VERSION + 1, 0))
#elif (TMPL_MINOR_VERSION % 2)
# define TMPL_VERSION_CUR_STABLE (G_ENCODE_VERSION (TMPL_MAJOR_VERSION, TMPL_MINOR_VERSION + 1))
#else
# define TMPL_VERSION_CUR_STABLE (G_ENCODE_VERSION (TMPL_MAJOR_VERSION, TMPL_MINOR_VERSION))
#endif

#if (TMPL_MINOR_VERSION == 99)
# define TMPL_VERSION_PREV_STABLE (G_ENCODE_VERSION (TMPL_MAJOR_VERSION + 1, 0))
#elif (TMPL_MINOR_VERSION % 2)
# define TMPL_VERSION_PREV_STABLE (G_ENCODE_VERSION (TMPL_MAJOR_VERSION, TMPL_MINOR_VERSION - 1))
#else
# define TMPL_VERSION_PREV_STABLE (G_ENCODE_VERSION (TMPL_MAJOR_VERSION, TMPL_MINOR_VERSION - 2))
#endif

/**
 * TMPL_VERSION_MIN_REQUIRED:
 *
 * A macro that should be defined by the user prior to including
 * the tmpl-glib.h header.
 *
 * The definition should be one of the predefined TMPL version
 * macros: %TMPL_VERSION_3_28, ...
 *
 * This macro defines the lower bound for the Template-GLib API to use.
 *
 * If a function has been deprecated in a newer version of Template-GLib,
 * it is possible to use this symbol to avoid the compiler warnings
 * without disabling warning for every deprecated function.
 *
 * Since: 3.28
 */
#ifndef TMPL_VERSION_MIN_REQUIRED
# define TMPL_VERSION_MIN_REQUIRED (TMPL_VERSION_CUR_STABLE)
#endif

/**
 * TMPL_VERSION_MAX_ALLOWED:
 *
 * A macro that should be defined by the user prior to including
 * the tmpl-glib.h header.

 * The definition should be one of the predefined Template-GLib version
 * macros: %TMPL_VERSION_1_0, %TMPL_VERSION_1_2,...
 *
 * This macro defines the upper bound for the TMPL API to use.
 *
 * If a function has been introduced in a newer version of Template-GLib,
 * it is possible to use this symbol to get compiler warnings when
 * trying to use that function.
 *
 * Since: 3.28
 */
#ifndef TMPL_VERSION_MAX_ALLOWED
# if TMPL_VERSION_MIN_REQUIRED > TMPL_VERSION_PREV_STABLE
#  define TMPL_VERSION_MAX_ALLOWED (TMPL_VERSION_MIN_REQUIRED)
# else
#  define TMPL_VERSION_MAX_ALLOWED (TMPL_VERSION_CUR_STABLE)
# endif
#endif

#if TMPL_VERSION_MAX_ALLOWED < TMPL_VERSION_MIN_REQUIRED
#error "TMPL_VERSION_MAX_ALLOWED must be >= TMPL_VERSION_MIN_REQUIRED"
#endif
#if TMPL_VERSION_MIN_REQUIRED < TMPL_VERSION_3_28
#error "TMPL_VERSION_MIN_REQUIRED must be >= TMPL_VERSION_3_28"
#endif

#define TMPL_AVAILABLE_IN_ALL                   _TMPL_EXTERN

#if TMPL_VERSION_MIN_REQUIRED >= TMPL_VERSION_3_28
# define TMPL_DEPRECATED_IN_3_28                TMPL_DEPRECATED
# define TMPL_DEPRECATED_IN_3_28_FOR(f)         TMPL_DEPRECATED_FOR(f)
#else
# define TMPL_DEPRECATED_IN_3_28                _TMPL_EXTERN
# define TMPL_DEPRECATED_IN_3_28_FOR(f)         _TMPL_EXTERN
#endif

#if TMPL_VERSION_MAX_ALLOWED < TMPL_VERSION_3_28
# define TMPL_AVAILABLE_IN_3_28                 TMPL_UNAVAILABLE(3, 28)
#else
# define TMPL_AVAILABLE_IN_3_28                 _TMPL_EXTERN
#endif

#if TMPL_VERSION_MIN_REQUIRED >= TMPL_VERSION_3_36
# define TMPL_DEPRECATED_IN_3_36                TMPL_DEPRECATED
# define TMPL_DEPRECATED_IN_3_36_FOR(f)         TMPL_DEPRECATED_FOR(f)
#else
# define TMPL_DEPRECATED_IN_3_36                _TMPL_EXTERN
# define TMPL_DEPRECATED_IN_3_36_FOR(f)         _TMPL_EXTERN
#endif

#if TMPL_VERSION_MAX_ALLOWED < TMPL_VERSION_3_36
# define TMPL_AVAILABLE_IN_3_36                 TMPL_UNAVAILABLE(3, 36)
#else
# define TMPL_AVAILABLE_IN_3_36                 _TMPL_EXTERN
#endif

#endif /* TMPL_VERSION_MACROS_H */
