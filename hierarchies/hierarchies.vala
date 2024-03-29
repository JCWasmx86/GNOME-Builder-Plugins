/* callhierarchy.vala
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
using Jsonrpc;

[CCode (cname = "wrap_call_async_finish")]
extern GLib.Variant ? wrap_call_async_finish (Ide.LspClient client, GLib.AsyncResult result) throws GLib.Error;
[CCode (cname = "hierarchies_get_resource")]
public static extern Resource hierarchies_get_resource ();

namespace Hierarchies {
    // From VLS
    class Position : Object {
        public uint line { get; set; default = -1; }
        public uint character { get; set; default = -1; }
    }
    class Range : Object {
        public Position start { get; set; }
        public Position end { get; set; }
    }
    class CallHierarchyItem : Object {
        public string name { get; set; }
        public string? detail { get; set; }
        public string uri { get; set; }
        public Range range { get; set; }
        public Range selectionRange { get; set; }
    }

    class CallHierarchyIncomingCall : Object {
        public CallHierarchyItem from { get; set; }
    }

    class CallHierarchyOutgoingCall : Object {
        public CallHierarchyItem to { get; set; }
    }

    class TypeHierarchyItem : Object {
        public string name { get; set; }
        public string? detail { get; set; }
        public string uri { get; set; }
        public Range range { get; set; }
        public Range selectionRange { get; set; }
    }
    // End from VLS

    public class WorkspaceAddin : GLib.Object, Ide.WorkspaceAddin {
        public void page_changed (Ide.Page? page) {
        }

        public void unload (Ide.Workspace workspace) {
        }

        public void load (Ide.Workspace workspace) {
            var pos = new Panel.Position ();
            pos.set_area (Panel.Area.START);
            pos.set_row (0);
            pos.set_depth (3);
            workspace.add_pane (new HierarchiesPanel (workspace, workspace.context.workdir.get_path ()), pos);
        }
    }

    private static Gtk.Box? INCOMING = null;
    private static Gtk.Box? OUTGOING = null;
    private static Gtk.Box? SUPER_TYPES = null;
    private static Gtk.Box? SUB_TYPES = null;

    public class HierarchiesPanel : Ide.Pane {
        private string directory;
        private Gtk.Box view;
        private Gtk.Box incoming;
        private Gtk.Box outgoing;
        private Gtk.Box supertypes;
        private Gtk.Box subtypes;

        construct {
            this.title = "Hierarchies";
            this.icon_name = "call-start-symbolic";
        }

        private Gtk.Box create_box (string icon, string label) {
            var b = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
            b.append (new Gtk.Image.from_icon_name (icon));
            b.append (new Gtk.Label (label));
            b.vexpand = false;
            b.hexpand = true;
            return b;
        }

        private Gtk.Box create_empty_box () {
            var b = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            b.vexpand = true;
            b.hexpand = true;
            return b;
        }

        private Gtk.ScrolledWindow wrap_scrollable (Gtk.Box b) {
            var s = new Gtk.ScrolledWindow ();
            s.child = b;
            return s;
        }

        public HierarchiesPanel (Ide.Workspace workspace, string dir) {
            Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).add_resource_path ("/plugins/hierarchies/icons");
            this.directory = dir;
            this.view = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.incoming = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.outgoing = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.subtypes = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.supertypes = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.incoming.vexpand = true;
            this.outgoing.vexpand = true;
            this.subtypes.vexpand = true;
            this.supertypes.vexpand = true;
            this.view.append (this.incoming);
            this.view.append (this.outgoing);
            this.view.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            this.view.append (this.supertypes);
            this.view.append (this.subtypes);
            this.incoming.append (create_box ("call-received-symbolic", "Incoming calls"));
            this.outgoing.append (create_box ("call-made-symbolic", "Outgoing calls"));
            this.supertypes.append (create_box ("call-made-symbolic", "Parent types"));
            this.subtypes.append (create_box ("call-received-symbolic", "Subtypes"));
            INCOMING = create_empty_box ();
            OUTGOING = create_empty_box ();
            SUB_TYPES = create_empty_box ();
            SUPER_TYPES = create_empty_box ();
            this.incoming.append (wrap_scrollable (INCOMING));
            this.outgoing.append (wrap_scrollable (OUTGOING));
            this.supertypes.append (wrap_scrollable (SUPER_TYPES));
            this.subtypes.append (wrap_scrollable (SUB_TYPES));
            this.realize.connect (() => {
                var sc = new Gtk.ScrolledWindow ();
                sc.child = view;
                this.set_child (sc);
            });
        }
    }

    class CHIData : GLib.Object {
        public Ide.LspClient client;
        public GLib.Variant variant;
        public CallHierarchyItem item;
        public Ide.Buffer buffer;

        public CHIData (Ide.LspClient client, Ide.Buffer buffer, GLib.Variant variant, CallHierarchyItem item) {
            this.client = client;
            this.buffer = buffer;
            this.variant = variant;
            this.item = item;
        }
    }

    class THIData : GLib.Object {
        public Ide.LspClient client;
        public GLib.Variant variant;
        public TypeHierarchyItem item;
        public Ide.Buffer buffer;

        public THIData (Ide.LspClient client, Ide.Buffer buffer, GLib.Variant variant, TypeHierarchyItem item) {
            this.client = client;
            this.buffer = buffer;
            this.variant = variant;
            this.item = item;
        }
    }

    public class HierarchiesPageAddin : Ide.Object, Ide.EditorPageAddin {
        private SimpleActionGroup map;
        private Ide.SourceView view;
        private unowned GLib.File file;
        private Ide.Workspace workspace;

        construct {
            this.map = new GLib.SimpleActionGroup ();
            var hierarchy = new SimpleAction ("callhierarchy", null);
            hierarchy.activate.connect (() => {
                var client = fetch_client ();
                if (client == null)
                    return;
                var buffer = (Ide.Buffer) this.view.buffer;
                this.create_call_hierarchy (buffer, client);
            });
            hierarchy.set_enabled (true);
            this.map.add_action (hierarchy);
            var types = new SimpleAction ("typehierarchy", null);
            types.activate.connect (() => {
                var client = fetch_client ();
                if (client == null)
                    return;
                var buffer = (Ide.Buffer) this.view.buffer;
                this.create_type_hierarchy (buffer, client);
            });
            types.set_enabled (true);
            this.map.add_action (types);
        }

        private Ide.LspClient? fetch_client () {
            var buffer = this.view.buffer as Ide.Buffer;
            if (buffer == null)
                return null;
            var rp = buffer.get_rename_provider ();
            if (rp == null)
                return null;
            var rplsp = rp as Ide.LspRenameProvider;
            if (rplsp == null)
                return null;
            return rplsp.client;
        }

        private void create_type_hierarchy (Ide.Buffer buffer, Ide.LspClient client) {
            var uri = buffer.dup_uri ();
            var sel = buffer.get_selection_range ();
            var line = sel.begin.line;
            var column = sel.begin.line_offset;
            var p = Jsonrpc.Message.new ("textDocument", "{",
                                         "uri", Jsonrpc.Message.PutString.create (uri),
                                         "}",
                                         "position", "{",
                                         "line", Jsonrpc.Message.PutInt32.create (line),
                                         "character", Jsonrpc.Message.PutInt32.create (column),
                                         "}");
            client.call_async.begin ("textDocument/prepareTypeHierarchy", p, null, (obj, res) => {
                try {
                    var ret = wrap_call_async_finish ((Ide.LspClient) obj, res);
                    while (true) {
                        if (SUB_TYPES.get_first_child () == null)
                            break;
                        SUB_TYPES.remove (SUB_TYPES.get_first_child ());
                    }
                    while (true) {
                        if (SUPER_TYPES.get_first_child () == null)
                            break;
                        SUPER_TYPES.remove (SUPER_TYPES.get_first_child ());
                    }
                    var iter = ret.iterator ();
                    var root_list_store_super = new GLib.ListStore (typeof (THIData));
                    var root_list_store_sub = new GLib.ListStore (typeof (THIData));
                    while (true) {
                        var child = iter.next_value ();
                        if (child == null) {
                            break;
                        }
                        var chi = (TypeHierarchyItem) Json.gobject_deserialize (typeof (TypeHierarchyItem), Json.gvariant_serialize (child));
                        root_list_store_super.append (new THIData (client, buffer, child, chi));
                        root_list_store_sub.append (new THIData (client, buffer, child, chi));
                    }
                    var tlm_i = new Gtk.TreeListModel (root_list_store_super, true, false, list_supertypes);
                    SUPER_TYPES.append (create_type_view (tlm_i));
                    var tlm_o = new Gtk.TreeListModel (root_list_store_sub, true, false, list_subtypes);
                    SUB_TYPES.append (create_type_view (tlm_o));
                } catch (Error e) {
                    critical ("%s", e.message);
                }
            });
        }

        private ListModel ? list_supertypes (Object item) {
            var thi = (THIData) item;
            var ls = new GLib.ListStore (typeof (THIData));
            var builder = new VariantBuilder (new VariantType ("a{sv}"));
            builder.add ("{sv}", "item", thi.variant);
            var p = builder.end ();
            thi.client.call_async.begin ("typeHierarchy/supertypes", p, null, (obj, res) => {
                try {
                    var ret = wrap_call_async_finish ((Ide.LspClient) obj, res);
                    var iter = ret.iterator ();
                    list_type_hierarchy_items (ls, thi, iter);
                } catch (Error e) {
                    critical ("%s", e.message);
                }
            });
            return new Gtk.TreeListModel (ls, true, false, list_supertypes);
        }

        private ListModel ? list_subtypes (Object item) {
            var thi = (THIData) item;
            var ls = new GLib.ListStore (typeof (THIData));
            var builder = new VariantBuilder (new VariantType ("a{sv}"));
            builder.add ("{sv}", "item", thi.variant);
            var p = builder.end ();
            thi.client.call_async.begin ("typeHierarchy/subtypes", p, null, (obj, res) => {
                try {
                    var ret = wrap_call_async_finish ((Ide.LspClient) obj, res);
                    var iter = ret.iterator ();
                    list_type_hierarchy_items (ls, thi, iter);
                } catch (Error e) {
                    critical ("%s", e.message);
                }
            });
            return new Gtk.TreeListModel (ls, true, false, list_subtypes);
        }

        private void list_type_hierarchy_items (GLib.ListStore ls, THIData thi, GLib.VariantIter iter) {
            while (true) {
                var child = iter.next_value ();
                if (child == null) {
                    break;
                }
                var chi1 = (TypeHierarchyItem) Json.gobject_deserialize (typeof (TypeHierarchyItem), Json.gvariant_serialize (child));
                var raw = new THIData (thi.client, thi.buffer, child, chi1);
                ls.append (raw);
            }
        }

        private void create_call_hierarchy (Ide.Buffer buffer, Ide.LspClient client) {
            var uri = buffer.dup_uri ();
            var sel = buffer.get_selection_range ();
            var line = sel.begin.line;
            var column = sel.begin.line_offset;
            var p = Jsonrpc.Message.new ("textDocument", "{",
                                         "uri", Jsonrpc.Message.PutString.create (uri),
                                         "}",
                                         "position", "{",
                                         "line", Jsonrpc.Message.PutInt32.create (line),
                                         "character", Jsonrpc.Message.PutInt32.create (column),
                                         "}");
            client.call_async.begin ("textDocument/prepareCallHierarchy", p, null, (obj, res) => {
                try {
                    var ret = wrap_call_async_finish ((Ide.LspClient) obj, res);
                    while (true) {
                        if (OUTGOING.get_first_child () == null)
                            break;
                        OUTGOING.remove (OUTGOING.get_first_child ());
                    }
                    while (true) {
                        if (INCOMING.get_first_child () == null)
                            break;
                        INCOMING.remove (INCOMING.get_first_child ());
                    }
                    var iter = ret.iterator ();
                    var root_list_store_i = new GLib.ListStore (typeof (CHIData));
                    var root_list_store_o = new GLib.ListStore (typeof (CHIData));
                    while (true) {
                        var child = iter.next_value ();
                        if (child == null) {
                            break;
                        }
                        var chi = (CallHierarchyItem) Json.gobject_deserialize (typeof (CallHierarchyItem), Json.gvariant_serialize (child));
                        root_list_store_i.append (new CHIData (client, buffer, child, chi));
                        root_list_store_o.append (new CHIData (client, buffer, child, chi));
                    }
                    var tlm_i = new Gtk.TreeListModel (root_list_store_i, true, false, list_incoming);
                    INCOMING.append (create_view (tlm_i));
                    var tlm_o = new Gtk.TreeListModel (root_list_store_o, true, false, list_outgoing);
                    OUTGOING.append (create_view (tlm_o));
                } catch (Error e) {
                    critical ("%s", e.message);
                }
            });
        }

        private Gtk.ListView create_view (Gtk.TreeListModel model) {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect (item => {
                var expander = new Gtk.TreeExpander ();
                var lbl = new Gtk.Label ("");
                expander.child = lbl;
                item.set_child (expander);
            });
            factory.bind.connect (item => {
                var chi = (CHIData) (((Gtk.ListItem) item).get_item ());
                var expander = (Gtk.TreeExpander) (((Gtk.ListItem) item).get_child ());
                var lbl = expander.child;
                expander.list_row = model.get_row (item.position);
                ((Gtk.Label) lbl).set_label (chi.item.name);
                if (chi.item.detail != null)
                    ((Gtk.Label) lbl).tooltip_text = chi.item.detail;
            });
            var list = new Gtk.ListView (new Gtk.SingleSelection (model), factory);
            list.activate.connect (idx => {
                var item = (CHIData) list.model.get_item (idx);
                var f = File.new_for_path (Uri.parse (item.item.uri, UriFlags.NONE).get_path ());
                var p = item.item.range.start;
                Ide.editor_focus_location (workspace, null, new Ide.Location (f, (int) p.line, (int) p.character));
            });
            return list;
        }

        private Gtk.ListView create_type_view (Gtk.TreeListModel model) {
            var factory = new Gtk.SignalListItemFactory ();
            factory.setup.connect (item => {
                var expander = new Gtk.TreeExpander ();
                var lbl = new Gtk.Label ("");
                expander.child = lbl;
                item.set_child (expander);
            });
            factory.bind.connect (item => {
                var chi = (THIData) (((Gtk.ListItem) item).get_item ());
                var expander = (Gtk.TreeExpander) (((Gtk.ListItem) item).get_child ());
                var lbl = expander.child;
                expander.list_row = model.get_row (item.position);
                ((Gtk.Label) lbl).set_label (chi.item.name);
                if (chi.item.detail != null)
                    ((Gtk.Label) lbl).tooltip_text = chi.item.detail;
            });
            var list = new Gtk.ListView (new Gtk.SingleSelection (model), factory);
            list.activate.connect (idx => {
                var item = (THIData) list.model.get_item (idx);
                var f = File.new_for_path (Uri.parse (item.item.uri, UriFlags.NONE).get_path ());
                var p = item.item.range.start;
                Ide.editor_focus_location (workspace, null, new Ide.Location (f, (int) p.line, (int) p.character));
            });
            return list;
        }

        private ListModel ? list_outgoing (Object item) {
            var chi = (CHIData) item;
            var ls = new GLib.ListStore (typeof (CHIData));
            var builder = new VariantBuilder (new VariantType ("a{sv}"));
            builder.add ("{sv}", "item", chi.variant);
            var p = builder.end ();
            chi.client.call_async.begin ("callHierarchy/outgoingCalls", p, null, (obj, res) => {
                try {
                    var ret = wrap_call_async_finish ((Ide.LspClient) obj, res);
                    var iter = ret.iterator ();
                    while (true) {
                        var child = iter.next_value ();
                        if (child == null) {
                            break;
                        }
                        var chi1 = (CallHierarchyOutgoingCall) Json.gobject_deserialize (typeof (CallHierarchyOutgoingCall), Json.gvariant_serialize (child));
                        var raw = new CHIData (chi.client, chi.buffer, extract_from_gvariant (child, "to"), chi1.to);
                        ls.append (raw);
                    }
                } catch (Error e) {
                    critical ("%s", e.message);
                }
            });
            return new Gtk.TreeListModel (ls, true, false, list_outgoing);
        }

        private ListModel ? list_incoming (Object item) {
            var chi = (CHIData) item;
            var ls = new GLib.ListStore (typeof (CHIData));
            var builder = new VariantBuilder (new VariantType ("a{sv}"));
            builder.add ("{sv}", "item", chi.variant);
            var p = builder.end ();
            chi.client.call_async.begin ("callHierarchy/incomingCalls", p, null, (obj, res) => {
                try {
                    var ret = wrap_call_async_finish ((Ide.LspClient) obj, res);
                    var iter = ret.iterator ();
                    while (true) {
                        var child = iter.next_value ();
                        if (child == null) {
                            break;
                        }
                        var chi1 = (CallHierarchyIncomingCall) Json.gobject_deserialize (typeof (CallHierarchyIncomingCall), Json.gvariant_serialize (child));
                        var raw = new CHIData (chi.client, chi.buffer, extract_from_gvariant (child, "from"), chi1.from);
                        ls.append (raw);
                    }
                } catch (Error e) {
                    critical ("%s", e.message);
                }
            });
            return new Gtk.TreeListModel (ls, true, false, list_incoming);
        }

        Variant extract_from_gvariant (Variant c, string str) {
            var iter = c.iterator ();
            while (true) {
                var v = iter.next_value ();
                if (v == null)
                    error ("OOPS");
                if (v.is_of_type (GLib.VariantType.DICTIONARY))
                    return v.lookup_value (str, null);
            }
        }

        public GLib.ActionGroup? ref_action_group () {
            return this.map;
        }

        public void unload (Ide.EditorPage page) {
            this.view = null;
        }

        public void load (Ide.EditorPage page) {
            this.workspace = Ide.widget_get_workspace (page);
            this.view = page.view;
            this.file = page.get_file ();
            var model = new GLib.Menu ();
            var mi = new GLib.MenuItem ("Show call hierarchy", "page.hierarchies.callhierarchy");
            model.append_item (mi);
            mi = new GLib.MenuItem ("Show type hierarchy", "page.hierarchies.typehierarchy");
            model.append_item (mi);
            view.append_menu (model);
            view.populate_menu.connect (() => {
                var s = this.map.lookup_action ("callhierarchy");
                ((SimpleAction) s).set_enabled (true);
                s = this.map.lookup_action ("typehierarchy");
                ((SimpleAction) s).set_enabled (true);
            });
        }

        public void frame_set (Ide.Frame frame) {
        }

        public void language_changed (string language_id) {
        }
    }
}

public void peas_register_types (TypeModule module) {
    var r = hierarchies_get_resource ();
    GLib.resources_register (r);
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (Hierarchies.WorkspaceAddin));
    obj.register_extension_type (typeof (Ide.EditorPageAddin), typeof (Hierarchies.HierarchiesPageAddin));
}
