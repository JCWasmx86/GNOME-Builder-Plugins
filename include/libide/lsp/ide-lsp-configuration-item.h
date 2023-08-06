/*
 * ide-lsp-configuration-item.h
 *
 * Copyright 2023 JCWasmx86 <JCWasmx86@t-online.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#pragma once

#if !defined (IDE_LSP_INSIDE) && !defined (IDE_LSP_COMPILATION)
# error "Only <libide-lsp.h> can be included directly."
#endif

#include <libide-code.h>


G_BEGIN_DECLS

#define IDE_TYPE_LSP_CONFIGURATION_ITEM (ide_lsp_configuration_item_get_type())

IDE_AVAILABLE_IN_ALL
G_DECLARE_FINAL_TYPE (IdeLspConfigurationItem, ide_lsp_configuration_item, IDE, LSP_CONFIGURATION_ITEM, GObject)

IdeLspConfigurationItem *ide_lsp_configuration_item_new (const char *section,
                                                         const char *scope_uri);

const char *
ide_lsp_configuration_item_get_scope_uri (IdeLspConfigurationItem *self);


const char *
ide_lsp_configuration_item_get_section (IdeLspConfigurationItem *self);
G_END_DECLS
