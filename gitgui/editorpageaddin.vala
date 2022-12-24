/* editorpageaddin.vala
 *
 * Copyright 2022 JCWasmx86 <JCWasmx86@t-online.de>
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
namespace GitGui {
    public class RevisionView : Gtk.Window {
        private GtkSource.View view;
        private Gtk.Box box;
        private string file;
        private string workdir;

        public RevisionView (File workdir, string file) {
            this.box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.file = workdir.get_relative_path (File.new_for_path (file));
            this.title = "Revisions of %s".printf (this.file);
            this.workdir = workdir.get_path ();
            this.view = new GtkSource.View ();
            var provider = new Gtk.CssProvider ();
            provider.load_from_data ("textview{font-family: Monospace;}".data);
            this.view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            this.view.set_show_line_numbers (true);
            this.view.editable = false;
            var grid = new Gtk.Grid ();
            grid.attach (this.box, 0, 0, 1, 1);
            grid.attach (this.view, 1, 0, 1, 1);
            this.view.vexpand = true;
            this.view.hexpand = true;
            var sc = new Gtk.ScrolledWindow ();
            sc.child = grid;
            this.child = sc;
            var parts = file.split ("/");
            var b = (parts != null && parts.length > 0) ? parts[parts.length - 1] : file;
            GtkSource.Buffer buf;
            var lang = GtkSource.LanguageManager.get_default ().guess_language (b, null);
            if (lang != null) {
                buf = new GtkSource.Buffer.with_language (lang);
                buf.highlight_syntax = true;
            } else {
                buf = new GtkSource.Buffer (null);
            }
            buf.style_scheme = GtkSource.StyleSchemeManager.get_default ().get_scheme ("Adwaita-dark");
            buf.text = "";
            this.view.buffer = buf;
            this.maximize ();
        }

        internal void register (string hash, string summary) {
            var row = new Adw.ActionRow ();
            row.title = Markup.escape_text (summary);
            row.subtitle = hash;
            row.has_tooltip = true;
            var gc = new Gtk.GestureClick ();
            gc.released.connect (() => {
                this.show_file (hash);
            });
            row.query_tooltip.connect ((x, y, kt, t) => {
                var commit_message = get_stdout (new string[] { "git", "show", hash, "--pretty=format:%B", "--no-patch" }, this.workdir).strip ();
                t.set_text (commit_message);
                return true;
            });
            row.add_controller (gc);
            this.box.append (row);
        }

        internal void show_file (string hash) {
            var f = get_stdout (new string[] { "git", "show", "%s:%s".printf (hash, this.file) }, this.workdir);
            this.view.buffer.text = f;
        }
    }

    public class GitEditorPageAddin : Ide.Object, Ide.EditorPageAddin {
        private SimpleActionGroup map;
        private Ide.SourceView view;
        private unowned GLib.File file;

        construct {
            this.map = new GLib.SimpleActionGroup ();
            var blame = new SimpleAction ("blame", null);
            blame.activate.connect (() => {
                Gtk.TextIter start, end;
                var non_zero = this.view.buffer.get_selection_bounds (out start, out end);
                var lines = new uint64[0];
                if (!non_zero) {
                    lines += start.get_line () + 1;
                } else {
                    for (var i = start.get_line (); i <= end.get_line (); i++)
                        lines += (i + 1);
                }
                foreach (var i in lines)
                    critical ("Blaming %llu", i);
                // TODO: Now render it.
            });
            this.map.add_action (blame);
            var revisions = new SimpleAction ("revisions", null);
            revisions.activate.connect (() => {
                critical ("%s", this.file.get_path ());
                var hashs = get_stdout (new string[] { "git", "log", "--format=%h|||%s", this.file.get_path () }, this.file.get_parent ().get_path ()).strip ();
                var split = hashs.split ("\n");
                var win = new RevisionView (this.get_context ().workdir, this.file.get_path ());
                win.present ();
                foreach (var h in split) {
                    var h1 = h.split ("|||");
                    win.register (h1[0], h1[1]);
                }
                if (split.length > 0)
                    win.show_file (split[0].split ("|||")[0]);
            });
            this.map.add_action (revisions);
        }

        public GLib.ActionGroup? ref_action_group () {
            return this.map;
        }

        public void unload (Ide.EditorPage page) {
            this.view = null;
        }

        public void load (Ide.EditorPage page) {
            this.view = page.view;
            this.file = page.get_file ();
            var model = new GLib.Menu ();
            var mi = new GLib.MenuItem ("Blame line(s)", "page.gitgui.blame");
            model.append_item (mi);
            mi = new GLib.MenuItem ("Show older revisions of this file", "page.gitgui.revisions");
            model.append_item (mi);
            view.append_menu (model);
            view.populate_menu.connect (() => {
                var s = this.map.lookup_action ("blame");
                ((SimpleAction) s).set_enabled (true);
                s = this.map.lookup_action ("revisions");
                ((SimpleAction) s).set_enabled (true);
            });
        }

        public void frame_set (Ide.Frame frame) {
        }

        public void language_changed (string language_id) {
        }
    }
}
