/*
 * dex-gio.h
 *
 * Copyright 2022 Christian Hergert <chergert@redhat.com>
 *
 * This library is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#include <gio/gio.h>

#include "dex-future.h"

G_BEGIN_DECLS

#define DEX_TYPE_FILE_INFO_LIST (dex_file_info_list_get_type())
#define DEX_TYPE_INET_ADDRESS_LIST (dex_inet_address_list_get_type())

DEX_AVAILABLE_IN_ALL
GType      dex_file_info_list_get_type    (void) G_GNUC_CONST;
DEX_AVAILABLE_IN_ALL
GType      dex_inet_address_list_get_type (void) G_GNUC_CONST;
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_make_directory        (GFile                    *file,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_copy                  (GFile                    *source,
                                           GFile                    *destination,
                                           GFileCopyFlags            flags,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_read                  (GFile                    *file,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_load_contents_bytes   (GFile                    *file);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_query_info            (GFile                    *file,
                                           const char               *attributes,
                                           GFileQueryInfoFlags       flags,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_replace               (GFile                    *file,
                                           const char               *etag,
                                           gboolean                  make_backup,
                                           GFileCreateFlags          flags,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_enumerate_children    (GFile                    *file,
                                           const char               *attributes,
                                           GFileQueryInfoFlags       flags,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_file_enumerator_next_files (GFileEnumerator          *file_enumerator,
                                           int                       num_files,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_input_stream_close         (GInputStream             *self,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_input_stream_read          (GInputStream             *self,
                                           gpointer                  buffer,
                                           gsize                     count,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_input_stream_read_bytes    (GInputStream             *self,
                                           gsize                     count,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_output_stream_close        (GOutputStream            *self,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_output_stream_splice       (GOutputStream            *output,
                                           GInputStream             *input,
                                           GOutputStreamSpliceFlags  flags,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_output_stream_write        (GOutputStream            *self,
                                           gconstpointer             buffer,
                                           gsize                     count,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_output_stream_write_bytes  (GOutputStream            *self,
                                           GBytes                   *bytes,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_socket_listener_accept     (GSocketListener          *listener);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_socket_client_connect      (GSocketClient            *socket_client,
                                           GSocketConnectable       *socket_connectable);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_io_stream_close            (GIOStream                *io_stream,
                                           int                       io_priority);
DEX_AVAILABLE_IN_ALL
DexFuture *dex_resolver_lookup_by_name    (GResolver                *resolver,
                                           const char               *address);

G_END_DECLS
