/* tmpl-symbol.h
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

#ifndef TMPL_SYMBOL_H
#define TMPL_SYMBOL_H

#include "tmpl-version-macros.h"

#include "tmpl-expr-types.h"

G_BEGIN_DECLS

TMPL_AVAILABLE_IN_ALL
TmplSymbol     *tmpl_symbol_new             (void);
TMPL_AVAILABLE_IN_ALL
TmplSymbol     *tmpl_symbol_ref             (TmplSymbol   *self);
TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_unref           (TmplSymbol   *self);
TMPL_AVAILABLE_IN_ALL
TmplSymbolType  tmpl_symbol_get_symbol_type (TmplSymbol   *self);
TMPL_AVAILABLE_IN_3_36
gboolean        tmpl_symbol_holds           (TmplSymbol   *self,
                                             GType         type);
TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_get_value       (TmplSymbol   *self,
                                             GValue       *value);
TMPL_AVAILABLE_IN_3_36
gpointer        tmpl_symbol_get_boxed       (TmplSymbol   *self);
TMPL_AVAILABLE_IN_ALL
TmplExpr       *tmpl_symbol_get_expr        (TmplSymbol   *self,
                                             GPtrArray   **params);
TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_assign_value    (TmplSymbol   *self,
                                             const GValue *value);
TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_assign_boolean  (TmplSymbol   *self,
                                             gboolean      v_bool);
TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_assign_double   (TmplSymbol   *self,
                                             gdouble       v_double);
TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_assign_string   (TmplSymbol   *self,
                                             const gchar  *v_string);
TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_assign_object   (TmplSymbol   *self,
                                             gpointer      v_object);
TMPL_AVAILABLE_IN_3_28
void            tmpl_symbol_assign_variant (TmplSymbol *self,
                                            GVariant   *v_variant);

TMPL_AVAILABLE_IN_3_28
void            tmpl_symbol_assign_strv    (TmplSymbol *self,
                                            const gchar **strv);

TMPL_AVAILABLE_IN_ALL
void            tmpl_symbol_assign_expr     (TmplSymbol   *self,
                                             TmplExpr     *expr,
                                             GPtrArray    *args);

G_END_DECLS

#endif /* TMPL_SYMBOL_H */
