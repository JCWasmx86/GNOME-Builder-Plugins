/*
 * Copyright (C) 2012 Igalia S.L.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#if !defined(__WEBKIT_H_INSIDE__) && !defined(__WEBKIT_WEB_EXTENSION_H_INSIDE__) && !defined(BUILDING_WEBKIT)
#error "Only <webkit/webkit.h> can be included directly."
#endif

#ifndef WebKitContextMenuItem_h
#define WebKitContextMenuItem_h

#include <gio/gio.h>
#include <webkit/WebKitDefines.h>
#include <webkit/WebKitContextMenu.h>
#include <webkit/WebKitContextMenuActions.h>

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define WEBKIT_TYPE_CONTEXT_MENU_ITEM            (webkit_context_menu_item_get_type())
#define WEBKIT_CONTEXT_MENU_ITEM(obj)            (G_TYPE_CHECK_INSTANCE_CAST((obj), WEBKIT_TYPE_CONTEXT_MENU_ITEM, WebKitContextMenuItem))
#define WEBKIT_IS_CONTEXT_MENU_ITEM(obj)         (G_TYPE_CHECK_INSTANCE_TYPE((obj), WEBKIT_TYPE_CONTEXT_MENU_ITEM))
#define WEBKIT_CONTEXT_MENU_ITEM_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST((klass),  WEBKIT_TYPE_CONTEXT_MENU_ITEM, WebKitContextMenuItemClass))
#define WEBKIT_IS_CONTEXT_MENU_ITEM_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass),  WEBKIT_TYPE_CONTEXT_MENU_ITEM))
#define WEBKIT_CONTEXT_MENU_ITEM_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS((obj),  WEBKIT_TYPE_CONTEXT_MENU_ITEM, WebKitContextMenuItemClass))

typedef struct _WebKitContextMenuItem        WebKitContextMenuItem;
typedef struct _WebKitContextMenuItemClass   WebKitContextMenuItemClass;
typedef struct _WebKitContextMenuItemPrivate WebKitContextMenuItemPrivate;

struct _WebKitContextMenuItem {
    GInitiallyUnowned parent;

    /*< private >*/
    WebKitContextMenuItemPrivate *priv;
};

struct _WebKitContextMenuItemClass {
    GInitiallyUnownedClass parent_class;

    /*< private >*/
    void (*_webkit_reserved0) (void);
    void (*_webkit_reserved1) (void);
    void (*_webkit_reserved2) (void);
    void (*_webkit_reserved3) (void);
};

WEBKIT_API GType
webkit_context_menu_item_get_type                         (void);


WEBKIT_API WebKitContextMenuItem *
webkit_context_menu_item_new_from_gaction                 (GAction                *action,
                                                           const gchar            *label,
                                                           GVariant               *target);

WEBKIT_API WebKitContextMenuItem *
webkit_context_menu_item_new_from_stock_action            (WebKitContextMenuAction action);

WEBKIT_API WebKitContextMenuItem *
webkit_context_menu_item_new_from_stock_action_with_label (WebKitContextMenuAction action,
                                                           const gchar            *label);

WEBKIT_API WebKitContextMenuItem *
webkit_context_menu_item_new_with_submenu                 (const gchar            *label,
                                                           WebKitContextMenu      *submenu);

WEBKIT_API WebKitContextMenuItem *
webkit_context_menu_item_new_separator                    (void);


WEBKIT_API GAction *
webkit_context_menu_item_get_gaction                      (WebKitContextMenuItem  *item);

WEBKIT_API WebKitContextMenuAction
webkit_context_menu_item_get_stock_action                 (WebKitContextMenuItem  *item);

WEBKIT_API gboolean
webkit_context_menu_item_is_separator                     (WebKitContextMenuItem  *item);

WEBKIT_API void
webkit_context_menu_item_set_submenu                      (WebKitContextMenuItem  *item,
                                                           WebKitContextMenu      *submenu);

WEBKIT_API WebKitContextMenu *
webkit_context_menu_item_get_submenu                      (WebKitContextMenuItem  *item);

G_END_DECLS

#endif
