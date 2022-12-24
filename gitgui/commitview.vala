/* commitview.vala
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
    public class CommitWindow : Adw.Window {
        private GtkSource.View view;
        private CommitExploreView explore;
        private CommitOverview overview;

        public CommitWindow (Commit c) {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            var header = new Adw.HeaderBar ();
            header.show_end_title_buttons = true;
            var title = new Adw.ViewSwitcherTitle ();
            header.title_widget = title;
            box.append (header);
            var buf = new GtkSource.Buffer (null);
            buf.language = GtkSource.LanguageManager.get_default ().get_language ("diff");
            buf.style_scheme = GtkSource.StyleSchemeManager.get_default ().get_scheme ("Adwaita-dark");
            this.view = new GtkSource.View.with_buffer (buf);
            this.view.editable = false;
            this.view.vexpand = true;
            this.view.hexpand = true;
            this.view.set_show_line_numbers (true);
            var provider = new Gtk.CssProvider ();
            provider.load_from_data ("textview{font-family: Monospace;}".data);
            this.view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            var sc = new Gtk.ScrolledWindow ();
            this.overview = new CommitOverview (c);
            sc.child = this.overview;
            var clamp = new Adw.Clamp ();
            clamp.maximum_size = 540;
            clamp.child = sc;
            var stack = new Adw.ViewStack ();
            // It seems like icon names are a must :(
            stack.add_titled (clamp, "overview", "Overview").icon_name = "general-properties-symbolic";
            sc = new Gtk.ScrolledWindow ();
            sc.child = this.view;
            this.explore = new CommitExploreView (c);
            // TODO: This icon makes no sense
            stack.add_titled (sc, "diff", "Diff").icon_name = "heal-symbolic";
            stack.add_titled (this.explore, "browse", "Browse tree at %s".printf (c.hash)).icon_name = "navigate-symbolic";
            title.stack = stack;
            box.append (stack);
            box.vexpand = true;
            box.hexpand = true;
            this.content = box;
            this.maximized = true;
            this.explore.vexpand = true;
            this.explore.hexpand = true;
            new Thread<void> ("commit-info-thread", () => {
                var diff = get_stdout (new string[] { "git", "diff", "%s^!".printf (c.hash) }, c.dir);
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    this.view.buffer.text = diff;
                    return Source.REMOVE;
                });
                var file_list = get_stdout (new string[] { "git", "ls-tree", c.hash, "-r" }, c.dir);
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    var files = file_list.split ("\n");
                    foreach (var f in files) {
                        if (f == null || f == "")
                            continue;
                        var name = f.split ("\t", 2)[1];
                        if (name != null)
                            this.explore.register_file (name);
                    }
                    return Source.REMOVE;
                });
                var commit_message = get_stdout (new string[] { "git", "show", c.hash, "--pretty=format:%B", "--no-patch" }, c.dir);
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    this.overview.commit_message.buffer.text = commit_message;
                    this.overview.author.label = "Author: %s <%s>".printf (c.author.name, c.author.email);
                    this.overview.committer.label = "Committed by: %s <%s>".printf (c.committer.name, c.committer.email);
                    this.overview.date.label = c.time.format ("%c");
                    return Source.REMOVE;
                });
                var added_files = get_stdout (new string[] { "git", "diff", "--name-only", "--diff-filter=A", c.hash + "^!" }, c.dir);
                var removed_files = get_stdout (new string[] { "git", "diff", "--name-only", "--diff-filter=D", c.hash + "^!" }, c.dir);
                var modified_files = get_stdout (new string[] { "git", "diff", "--name-only", "--diff-filter=M", c.hash + "^!" }, c.dir);
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    var af = added_files.split ("\n");
                    foreach (var a in af) {
                        if (a == null || a.length < 2)
                            continue;
                        this.overview.added_files.append (new AddedFileWidget (a, get_stdout (new string[] { "git", "diff", c.hash + "^!", "--shortstat", "--", a }, c.dir)));
                    }
                    af = removed_files.split ("\n");
                    foreach (var a in af) {
                        if (a == null || a.length < 2)
                            continue;
                        this.overview.removed_files.append (new RemovedFileWidget (a, get_stdout (new string[] { "git", "diff", c.hash + "^!", "--shortstat", "--", a }, c.dir)));
                    }
                    af = modified_files.split ("\n");
                    foreach (var a in af) {
                        if (a == null || a.length < 2)
                            continue;
                        this.overview.changed_files.append (new ChangedFileWidget (a, get_stdout (new string[] { "git", "diff", c.hash + "^!", "--shortstat", "--", a }, c.dir)));
                    }
                    return Source.REMOVE;
                });
            });
        }
    }

    public abstract class FileWidget : Adw.ActionRow {
        protected Gtk.Image image;

        protected FileWidget (string name) {
            this.title = name;
            this.image = new Gtk.Image.from_icon_name ("foo");
            this.add_prefix (this.image);
        }

        protected void fill (string s) {
            var parts = s.split (" ");
            var added = parts[4];
            var removed = parts[6] ?? "0";
            if (!s.contains ("insertion")) {
                removed = added;
                added = "0";
            }
            var l = new Gtk.Label ("<span foreground='green'>+%s</span>".printf (added));
            l.use_markup = true;
            l.label = "<span foreground='green'>+%s</span>".printf (added);
            this.add_suffix (l);
            l = new Gtk.Label ("<span foreground='red'>-%s</span>".printf (removed));
            l.use_markup = true;
            l.label = "<span foreground='red'>-%s</span>".printf (removed);
            this.add_suffix (l);
        }
    }

    public class AddedFileWidget : FileWidget {
        public AddedFileWidget (string name, string change) {
            base (name);
            this.image.icon_name = "plus-symbolic";
            this.fill (change);
        }
    }

    public class RemovedFileWidget : FileWidget {
        public RemovedFileWidget (string name, string change) {
            base (name);
            this.image.icon_name = "cross-filled-symbolic";
            this.fill (change);
        }
    }

    public class ChangedFileWidget : FileWidget {
        public ChangedFileWidget (string name, string change) {
            base (name);
            this.image.icon_name = "edit-symbolic";
            this.fill (change);
        }
    }

    public class CommitOverview : Gtk.Box {
        internal Gtk.TextView commit_message;
        internal Gtk.Label author;
        internal Gtk.Label committer;
        internal Gtk.Label date;
        internal Gtk.Box added_files;
        internal Gtk.Box removed_files;
        internal Gtk.Box changed_files;

        public CommitOverview (Commit c) {
            this.orientation = Gtk.Orientation.VERTICAL;
            this.commit_message = new Gtk.TextView ();
            this.commit_message.editable = false;
            this.append (this.commit_message);
            var tmp_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.author = new Gtk.Label ("");
            this.committer = new Gtk.Label ("");
            this.date = new Gtk.Label ("");
            tmp_box.append (this.author);
            tmp_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            tmp_box.append (this.committer);
            tmp_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            tmp_box.append (this.date);
            tmp_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            tmp_box.append (new Gtk.Label (c.hash));
            tmp_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            this.append (tmp_box);
            this.added_files = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.removed_files = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.changed_files = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.append (this.added_files);
            this.append (this.removed_files);
            this.append (this.changed_files);
        }
    }

    public class CommitExploreView : Gtk.Box {
        private Gtk.Box left_side;
        private GtkSource.View view;
        private Commit commit;

        public CommitExploreView (Commit c) {
            this.commit = c;
            this.orientation = Gtk.Orientation.HORIZONTAL;
            this.left_side = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            this.left_side.hexpand = false;
            this.left_side.width_request = 200;
            this.left_side.vexpand = true;
            var buf = new GtkSource.Buffer (null);
            buf.style_scheme = GtkSource.StyleSchemeManager.get_default ().get_scheme ("Adwaita-dark");
            this.view = new GtkSource.View.with_buffer (buf);
            this.view.editable = false;
            this.view.vexpand = true;
            this.view.hexpand = true;
            var sc = new Gtk.ScrolledWindow ();
            sc.child = this.left_side;
            sc.hscrollbar_policy = Gtk.PolicyType.NEVER;
            this.append (sc);
            sc = new Gtk.ScrolledWindow ();
            var provider = new Gtk.CssProvider ();
            provider.load_from_data ("textview{font-family: Monospace;}".data);
            this.view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            sc.child = this.view;
            this.view.set_show_line_numbers (true);
            this.append (sc);
        }

        public void register_file (string n) {
            var l = new Gtk.Label (n);
            l.xalign = 0;
            l.tooltip_text = n;
            l.ellipsize = Pango.EllipsizeMode.MIDDLE;
            l.max_width_chars = 64;
            var gc = new Gtk.GestureClick ();
            gc.pressed.connect ((n, x, y) => {
                var s = l.label;
                var parts = s.split ("/");
                var b = (parts != null && parts.length > 0) ? parts[parts.length - 1] : s;
                var content = get_stdout (new string[] { "git", "show", "%s:%s".printf (this.commit.hash, s) }, this.commit.dir);
                GtkSource.Buffer buf;
                var lang = GtkSource.LanguageManager.get_default ().guess_language (b, null);
                if (lang != null) {
                    buf = new GtkSource.Buffer.with_language (lang);
                    buf.highlight_syntax = true;
                } else {
                    buf = new GtkSource.Buffer (null);
                }
                buf.style_scheme = GtkSource.StyleSchemeManager.get_default ().get_scheme ("Adwaita-dark");
                buf.text = content;
                this.view.buffer = buf;
            });
            l.add_controller (gc);
            this.left_side.append (l);
        }
    }
}
