/* scriptdir.vala
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
[CCode (cname = "scriptdir_get_resource")]
public static extern Resource scriptdir_get_resource ();

namespace ScriptDir {
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
            workspace.add_pane (new ScriptPanel (workspace, workspace.context.workdir.get_path ()), pos);
        }
    }

    public class ScriptPanel : Ide.Pane {
        private string directory;
        private ScriptList view;

        construct {
            this.title = "Scripts";
            this.icon_name = "note-symbolic";
        }

        public ScriptPanel (Ide.Workspace workspace, string dir) {
            Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).add_resource_path ("/plugins/scriptdir/icons");
            this.directory = dir;
            this.view = new ScriptList (workspace, dir);
            this.realize.connect (() => {
                this.set_child (view);
            });
        }
    }

    public class ScriptList : Adw.Bin {
        private string cwd;
        private string script_dir;
        private GLib.ListStore model;
        private Gtk.SignalListItemFactory factory;
        private Gtk.SelectionModel selection_model;
        private GLib.FileMonitor monitor;

        public ScriptList (Ide.Workspace workspace, string cwd) {
            this.cwd = cwd;
            this.script_dir = Environment.get_home_dir () + "/.local/share/gnome-builder/scripts";
            try {
                var file = File.new_for_path (this.script_dir);
                file.make_directory_with_parents ();
            } catch (Error e) {
                info ("%s", e.message);
            }
            this.model = new GLib.ListStore (typeof (ScriptEntry));
            try {
                var file = File.new_for_path (this.script_dir);
                this.monitor = file.monitor_directory (GLib.FileMonitorFlags.NONE, null);
                var enumerator = file.enumerate_children (FileAttribute.STANDARD_NAME, 0);
                FileInfo file_info;
                while ((file_info = enumerator.next_file ()) != null) {
                    info ("Found script %s", file_info.get_name ());
                    var se = new ScriptEntry (this.script_dir + "/" + file_info.get_name ());
                    if (se.success)
                        this.model.append (se);
                }
            } catch (Error e) {
                critical ("%s", e.message);
            }
            this.factory = new Gtk.SignalListItemFactory ();
            this.selection_model = new Gtk.SingleSelection (this.model);
            this.factory.setup.connect (item => {
                var row = new ScriptEntryRow ();
                row.btn.clicked.connect (() => {
                    var script = (ScriptEntry) (((Gtk.ListItem) item).get_item ());
                    info ("Executing script \"%s\"", script.name);
                    var sip = new ScriptIdePage (this.cwd, script);
                    var p = new Panel.Position ();
                    workspace.add_page (sip, p);
                    sip.raise ();
                    sip.grab_focus ();
                });
                ((Gtk.ListItem) item).set_child (row);
            });
            this.factory.bind.connect (item => {
                var script = (ScriptEntry) (((Gtk.ListItem) item).get_item ());
                var row = (ScriptEntryRow) (((Gtk.ListItem) item).get_child ());
                row.set_title (script.name);
                row.set_subtitle (script.description);
            });
            var sc = new Gtk.ScrolledWindow ();
            var listview = new Gtk.ListView (this.selection_model, this.factory);
            sc.child = listview;
            this.child = sc;
            listview.activate.connect (idx => {
                // Nothing
            });
        }
    }

    public class ScriptIdePage : Ide.Page {
        public ScriptIdePage (string cwd, ScriptEntry e) {
            this.title = "TTY for \"%s\"@%s".printf (e.name, new GLib.DateTime.now_local ().format ("%c"));
            this.icon_name = "tty-symbolic";
            var vte = new Ide.Terminal ();
            string[] res = {};
            foreach (var env in Environ.get ()) {
                res += env;
            }
            res += "PATH=/app/bin:/usr/bin:/usr/local/bin:/var/run/host/usr/bin/:/var/run/host/usr/local/bin/";
            vte.vexpand = true;
            vte.hexpand = true;
            vte.spawn_async (Vte.PtyFlags.DEFAULT, cwd, { "flatpak-spawn", "--host", e.path }, res, 0, null, int.MAX, null, null);
            var sc = new Gtk.ScrolledWindow ();
            sc.child = vte;
            this.child = sc;
        }
    }

    public class ScriptEntryRow : Adw.ActionRow {
        internal Gtk.Button btn;

        public ScriptEntryRow () {
            this.btn = new Gtk.Button.from_icon_name ("execute-from-symbolic");
            btn.hexpand = false;
            btn.vexpand = false;
            btn.valign = Gtk.Align.CENTER;
            btn.halign = Gtk.Align.CENTER;
            btn.set_size_request (16, 16);
            btn.get_style_context ().add_class ("flat");
            this.add_suffix (btn);
        }
    }

    public class ScriptEntry : Object {
        public string path;
        public bool success;
        public string? name;
        public string? description;
        public bool requires_tty;

        public ScriptEntry (string path) {
            this.path = path;
            var stderr = "";
            var stdout = "";
            var code = 0;
            this.success = false;
            try {
                Process.spawn_sync ("/tmp", { path, "--info" }, Environ.get (), GLib.SpawnFlags.SEARCH_PATH, null, out stdout, out stderr, out code);
                this.success = code == 0;
                if (code == 0 && stdout != null && (stdout.strip ().split ("||").length == 3)) {
                    var parts = stdout.strip ().split ("||", 3);
                    this.name = parts[0].strip ();
                    this.description = parts[1].strip ();
                    this.requires_tty = parts[2] == "tty";
                } else {
                    critical ("%d %s %s", code, stdout, stderr);
                }
            } catch (Error e) {
                critical ("%s", e.message);
                this.success = false;
            }
        }
    }
}
public void peas_register_types (TypeModule module) {
    var r = scriptdir_get_resource ();
    GLib.resources_register (r);
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (ScriptDir.WorkspaceAddin));
}

