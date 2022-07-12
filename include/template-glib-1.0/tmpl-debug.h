/* tmpl-debug.h.in
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

#ifndef TMPL_DEBUG_H
#define TMPL_DEBUG_H

#include <glib.h>

G_BEGIN_DECLS

#ifndef TMPL_ENABLE_TRACE
# define TMPL_ENABLE_TRACE 0
#endif
#if TMPL_ENABLE_TRACE != 1
# undef TMPL_ENABLE_TRACE
#endif

#define TMPL_LOG_LEVEL_TRACE (1 << TMPL_LOG_LEVEL_USER_SHIFT)

#ifdef TMPL_ENABLE_TRACE
# define TMPL_TRACE_MSG(fmt, ...)                                         \
   g_log(G_LOG_DOMAIN, TMPL_LOG_LEVEL_TRACE, "  MSG: %s():%d: "fmt,       \
         G_STRFUNC, __LINE__, ##__VA_ARGS__)
# define TMPL_PROBE                                                       \
   g_log(G_LOG_DOMAIN, TMPL_LOG_LEVEL_TRACE, "PROBE: %s():%d",            \
         G_STRFUNC, __LINE__)
# define TMPL_TODO(_msg)                                                  \
   g_log(G_LOG_DOMAIN, TMPL_LOG_LEVEL_TRACE, " TODO: %s():%d: %s",        \
         G_STRFUNC, __LINE__, _msg)
# define TMPL_ENTRY                                                       \
   g_log(G_LOG_DOMAIN, TMPL_LOG_LEVEL_TRACE, "ENTRY: %s():%d",            \
         G_STRFUNC, __LINE__)
# define TMPL_EXIT                                                        \
   G_STMT_START {                                                         \
      g_log(G_LOG_DOMAIN, TMPL_LOG_LEVEL_TRACE, " EXIT: %s():%d",         \
            G_STRFUNC, __LINE__);                                         \
      return;                                                             \
   } G_STMT_END
# define TMPL_GOTO(_l)                                                    \
   G_STMT_START {                                                         \
      g_log(G_LOG_DOMAIN, TMPL_LOG_LEVEL_TRACE, " GOTO: %s():%d ("#_l")", \
            G_STRFUNC, __LINE__);                                         \
      goto _l;                                                            \
   } G_STMT_END
# define TMPL_RETURN(_r)                                                  \
   G_STMT_START {                                                         \
      g_log(G_LOG_DOMAIN, TMPL_LOG_LEVEL_TRACE, " EXIT: %s():%d ",        \
            G_STRFUNC, __LINE__);                                         \
      return _r;                                                          \
   } G_STMT_END
#else
# define TMPL_TODO(_msg)
# define TMPL_PROBE
# define TMPL_TRACE_MSG(fmt, ...)
# define TMPL_ENTRY
# define TMPL_GOTO(_l)   goto _l
# define TMPL_EXIT       return
# define TMPL_RETURN(_r) return _r
#endif

G_END_DECLS

#endif /* TMPL_DEBUG_H */
