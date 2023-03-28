/*
 * dex-scheduler.h
 *
 * Copyright 2022 Christian Hergert <chergert@gnome.org>
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

#if !defined (DEX_INSIDE) && !defined (DEX_COMPILATION)
# error "Only <libdex.h> can be included directly."
#endif

#include "dex-future.h"

G_BEGIN_DECLS

#define DEX_TYPE_SCHEDULER    (dex_scheduler_get_type())
#define DEX_SCHEDULER(obj)    (G_TYPE_CHECK_INSTANCE_CAST(obj, DEX_TYPE_SCHEDULER, DexScheduler))
#define DEX_IS_SCHEDULER(obj) (G_TYPE_CHECK_INSTANCE_TYPE(obj, DEX_TYPE_SCHEDULER))

typedef struct _DexScheduler DexScheduler;

typedef void       (*DexSchedulerFunc) (gpointer func_data);
typedef DexFuture *(*DexFiberFunc)     (gpointer func_data);

DEX_AVAILABLE_IN_ALL
GType         dex_scheduler_get_type           (void) G_GNUC_CONST;
DEX_AVAILABLE_IN_ALL
DexScheduler *dex_scheduler_get_thread_default (void);
DEX_AVAILABLE_IN_ALL
DexScheduler *dex_scheduler_ref_thread_default (void);
DEX_AVAILABLE_IN_ALL
DexScheduler *dex_scheduler_get_default        (void);
DEX_AVAILABLE_IN_ALL
GMainContext *dex_scheduler_get_main_context   (DexScheduler     *scheduler);
DEX_AVAILABLE_IN_ALL
void          dex_scheduler_push               (DexScheduler     *scheduler,
                                                DexSchedulerFunc  func,
                                                gpointer          func_data);
DEX_AVAILABLE_IN_ALL
DexFuture    *dex_scheduler_spawn              (DexScheduler     *scheduler,
                                                gsize             stack_size,
                                                DexFiberFunc      func,
                                                gpointer          func_data,
                                                GDestroyNotify    func_data_destroy);

G_DEFINE_AUTOPTR_CLEANUP_FUNC (DexScheduler, dex_unref)

G_END_DECLS
