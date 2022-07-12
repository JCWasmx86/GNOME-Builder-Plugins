/* tmpl-expr.h
 *
 * Copyright (C) 2016 Christian Hergert <chergert@redhat.com>
 *
 * This file is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#if !defined (TMPL_GLIB_INSIDE) && !defined (TMPL_GLIB_COMPILATION)
# error "Only <tmpl-glib.h> can be included directly."
#endif

#ifndef TMPL_EXPR_H
#define TMPL_EXPR_H

#include "tmpl-version-macros.h"

#include "tmpl-expr-types.h"

G_BEGIN_DECLS

TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_from_string       (const gchar      *str,
                                       GError          **error);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_ref               (TmplExpr         *expr);
TMPL_AVAILABLE_IN_ALL
void      tmpl_expr_unref             (TmplExpr         *expr);
TMPL_AVAILABLE_IN_ALL
gboolean  tmpl_expr_eval              (TmplExpr         *expr,
                                       TmplScope        *scope,
                                       GValue           *return_value,
                                       GError          **error);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_boolean       (gboolean          value);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_invert_boolean(TmplExpr         *left);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_getattr       (TmplExpr         *left,
                                       const gchar      *attr);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_setattr       (TmplExpr         *left,
                                       const gchar      *attr,
                                       TmplExpr         *right);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_require       (const gchar      *typelib,
                                       const gchar      *version);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_simple        (TmplExprType      type,
                                       TmplExpr         *left,
                                       TmplExpr         *right);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_string        (const gchar      *value,
                                       gssize            length);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_number        (gdouble           value);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_gi_call       (TmplExpr         *left,
                                       const gchar      *name,
                                       TmplExpr         *params);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_fn_call       (TmplExprBuiltin   builtin,
                                       TmplExpr         *param);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_user_fn_call  (const gchar      *name,
                                       TmplExpr         *param);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_flow          (TmplExprType      type,
                                       TmplExpr         *condition,
                                       TmplExpr         *primary,
                                       TmplExpr         *secondary);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_symbol_ref    (const gchar      *symbol);
TMPL_AVAILABLE_IN_ALL
TmplExpr *tmpl_expr_new_symbol_assign (const gchar      *symbol,
                                       TmplExpr         *right);
TMPL_AVAILABLE_IN_3_36
TmplExpr *tmpl_expr_new_stmt_list     (GPtrArray        *stmts);
TMPL_AVAILABLE_IN_3_36
TmplExpr *tmpl_expr_new_func          (char             *name,
                                       char            **symlist,
                                       TmplExpr         *list);
TMPL_AVAILABLE_IN_3_36
TmplExpr *tmpl_expr_new_anon_call     (TmplExpr         *func,
                                       TmplExpr         *params);
TMPL_AVAILABLE_IN_3_36
TmplExpr *tmpl_expr_new_nop           (void);
TMPL_AVAILABLE_IN_3_36
TmplExpr *tmpl_expr_new_null          (void);

G_DEFINE_AUTOPTR_CLEANUP_FUNC (TmplExpr, tmpl_expr_unref)

G_END_DECLS

#endif /* TMPL_EXPR_H */
