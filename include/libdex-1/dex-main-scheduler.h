/*
 * dex-main-scheduler.h
 *
 * Copyright 2022 Christian Hergert <chergert@redhat.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#include "dex-scheduler.h"

G_BEGIN_DECLS

#define DEX_TYPE_MAIN_SCHEDULER    (dex_main_scheduler_get_type())
#define DEX_MAIN_SCHEDULER(obj)    (G_TYPE_CHECK_INSTANCE_CAST(obj, DEX_TYPE_MAIN_SCHEDULER, DexMainScheduler))
#define DEX_IS_MAIN_SCHEDULER(obj) (G_TYPE_CHECK_INSTANCE_TYPE(obj, DEX_TYPE_MAIN_SCHEDULER))

typedef struct _DexMainScheduler DexMainScheduler;

DEX_AVAILABLE_IN_ALL
GType dex_main_scheduler_get_type (void) G_GNUC_CONST;

G_DEFINE_AUTOPTR_CLEANUP_FUNC (DexMainScheduler, dex_unref)

G_END_DECLS
