/* gitgui.vala
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
[CCode (cname = "gitgui_get_resource")]
public static extern Resource gitgui_get_resource ();

namespace GitGui {
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
            workspace.add_pane (new GPanel (workspace.context.workdir.get_path ()), pos);
        }
    }

    public class GPanel : Ide.Pane {
        private string directory;
        private View view;
        construct {
            this.title = "Git";
            this.icon_name = "branch-symbolic";
        }

        public GPanel (string dir) {
            Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).add_resource_path ("/plugins/gitgui/icons");
            this.directory = dir;
            this.view = new View (dir);
            this.realize.connect (() => {
                this.set_child (view);
            });
        }
    }

    public class View : Adw.Bin {
        private string directory;
        private Gtk.Stack stack;
        private Action action;
        private Thread<void> thread;

        public View (string dir) {
            this.directory = dir;
            this.stack = new Gtk.Stack ();
            this.child = this.stack;
            this.action = new Action (dir);
            this.thread = new Thread<void> (".git/config watcher", () => {
                var ifd = Linux.inotify_init ();
                info ("FD: %d", ifd);
                if (ifd == -1)
                    return;
                // This is cursed
                while (true) {
                    var full_path = dir + "/.git/config";
                    info ("Waiting for %s", full_path);
                    while (true) {
                        Posix.Stat buf;
                        if (Posix.stat (full_path, out buf) == 0)
                            break;
                        Posix.sleep (1);
                    }
                    info ("%s exists now", full_path);
                    this.created_config ();
                    Posix.Stat buf;
                    Posix.stat (full_path, out buf);
                    var mtime = buf.st_mtime;
                    var ino = buf.st_ino;
                    Posix.Stat idx_buf;
                    Posix.stat (dir + "/.git/index", out idx_buf);
                    var mtime_idx = idx_buf.st_mtime;
                    Posix.Stat heads_buf;
                    Posix.stat (dir + "/.git/logs/refs/heads/", out heads_buf);
                    var mtime_heads = heads_buf.st_mtime;
                    var ino_heads = heads_buf.st_ino;
                    var fd = Linux.inotify_add_watch (ifd, dir + "/.git/",
                                                      Linux.InotifyMaskFlags.ACCESS | Linux.InotifyMaskFlags.MODIFY | Linux.InotifyMaskFlags.ATTRIB
                                                      | Linux.InotifyMaskFlags.CLOSE_WRITE | Linux.InotifyMaskFlags.CLOSE_NOWRITE
                                                      | Linux.InotifyMaskFlags.OPEN | Linux.InotifyMaskFlags.MOVED_FROM
                                                      | Linux.InotifyMaskFlags.MOVED_TO | Linux.InotifyMaskFlags.CREATE
                                                      | Linux.InotifyMaskFlags.DELETE | Linux.InotifyMaskFlags.DELETE_SELF
                                                      | Linux.InotifyMaskFlags.MOVE_SELF);
                    while (true) {
                        Linux.InotifyEvent evt = { 0 };
                        Posix.read (ifd, &evt, sizeof (Linux.InotifyEvent) + Posix.Limits.NAME_MAX + 1);
                        var r = Posix.stat (full_path, out buf);
                        var updated_config = r == 0 && buf.st_ino == ino && buf.st_mtime > mtime;
                        r = Posix.stat (dir + "/.git/index", out idx_buf);
                        var updated_index = r == 0 && idx_buf.st_mtime > mtime_idx;
                        r = Posix.stat (dir + "/.git/logs/refs/heads/", out heads_buf);
                        var updated_heads = r == 0 && heads_buf.st_ino == ino_heads && heads_buf.st_mtime > mtime_heads;
                        if (evt.len > 0) {
                            info ("Event: %s (0x%x)", (string) evt.name, evt.mask);
                            if ((evt.mask & Linux.InotifyMaskFlags.CREATE) != 0 || (evt.mask & Linux.InotifyMaskFlags.OPEN) != 0) {
                                if (updated_config || updated_index || updated_heads) {
                                    this.created_config ();
                                    mtime = buf.st_mtime;
                                    mtime_idx = idx_buf.st_mtime;
                                    mtime_heads = heads_buf.st_mtime;
                                }
                            } else if ((evt.mask & Linux.InotifyMaskFlags.DELETE) != 0) {
                                if (Posix.stat (full_path, out buf) != 0) {
                                    this.deleted_config ();
                                    break;
                                }
                            } else if ((evt.mask & Linux.InotifyMaskFlags.MODIFY) != 0) {
                                if (updated_config || updated_index || updated_heads) {
                                    this.edited_config ();
                                    mtime = buf.st_mtime;
                                    mtime_idx = idx_buf.st_mtime;
                                    mtime_heads = heads_buf.st_mtime;
                                }
                            } else {
                                info ("Unhandled event: %u", evt.mask);
                            }
                        }
                    }
                    Linux.inotify_rm_watch (ifd, fd);
                }
                // Posix.close (fd);
            });
            this.stack.add_named (this.action, "action");
            var create_repo = new Adw.StatusPage ();
            create_repo.title = "No git repository";
            var create_repo_button = new Gtk.Button.with_label ("Create Repository");
            create_repo_button.get_style_context ().add_class ("suggested-action");
            create_repo.child = create_repo_button;
            this.stack.add_named (create_repo, "create");
            Posix.Stat buf;
            var full_path = dir + "/.git/config";
            if (Posix.stat (full_path, out buf) != -1) {
                this.stack.visible_child_name = "action";
                this.action.reload ();
            } else {
                this.stack.visible_child_name = "create";
            }
        }

        internal void created_config () {
            info ("Created config");
            if (this.stack.visible_child_name == "create") {
                this.stack.visible_child = this.action;
            }
            this.action.reload ();
        }

        internal void deleted_config () {
            info ("Deleted config");
            if (this.stack.visible_child_name == "action") {
                this.stack.visible_child_name = "create";
            }
            this.action.reload ();
        }

        internal void edited_config () {
            info ("Edited config");
            if (this.stack.visible_child_name == "create") {
                this.stack.visible_child = this.action;
            }
            this.action.reload ();
        }
    }

    public class Action : Adw.Bin {
        private string directory;
        private ListView<Remote> remotes;
        private ListView<Branch> branches;
        private ListView<Commit> commits;

        public Action (string dir) {
            this.directory = dir;
            var b = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            var stack = new Adw.ViewStack ();
            this.remotes = new ListView<Remote> (dir, create_remote);
            this.branches = new ListView<Branch> (dir, create_branch);
            this.commits = new ListView<Commit> (dir, create_commit);
            this.add (stack, this.remotes, "remote", "Remotes", "folder-remote-symbolic");
            this.add (stack, this.branches, "branch", "Branches", "git-branch-symbolic");
            this.add (stack, this.commits, "commits", "Commits", "gear-symbolic");
            stack.hexpand = true;
            stack.vexpand = true;
            var bar = new Adw.ViewSwitcherBar ();
            b.append (stack);
            b.append (bar);
            bar.stack = stack;
            bar.reveal = true;
            this.child = b;
        }

        private void add (Adw.ViewStack stack, Gtk.Widget w, string id, string title, string icon) {
            var sc = new Gtk.ScrolledWindow ();
            sc.child = w;
            w.hexpand = true;
            w.vexpand = true;
            sc.hexpand = true;
            sc.vexpand = true;
            stack.add_titled (sc, id, title).icon_name = icon;
        }

        private static Gtk.Widget create_remote (Object obj) {
            var row = new Adw.ActionRow ();
            row.title = Markup.escape_text (((Remote) obj).name);
            row.subtitle = Markup.escape_text (((Remote) obj).uri);
            return row;
        }

        private static Gtk.Widget create_branch (Object obj) {
            var row = new Adw.ActionRow ();
            row.title = Markup.escape_text (((Branch) obj).name);
            var is_active = ((Branch) obj).is_active;
            if (is_active)
                row.subtitle = "Current branch";
            return row;
        }

        private static Gtk.Widget create_commit (Object obj) {
            var row = new Adw.ActionRow ();
            row.title = Markup.escape_text (((Commit) obj).message_first_line);
            row.subtitle = Markup.escape_text (((Commit) obj).hash);
            var more_button = new Gtk.Button ();
            more_button.icon_name = "view-more-horizontal-symbolic";
            more_button.hexpand = false;
            more_button.vexpand = false;
            more_button.height_request = 16;
            more_button.width_request = 16;
            more_button.margin_start = 0;
            more_button.margin_end = 0;
            more_button.margin_top = 0;
            more_button.margin_bottom = 0;
            more_button.tooltip_text = "Show more information";
            more_button.get_style_context ().add_class ("flat");
            more_button.clicked.connect (() => {
                var w = new CommitWindow ((Commit) obj);
                w.present ();
            });
            row.add_suffix (more_button);
            return row;
        }

        public void reload () {
            new Thread<void> ("git-update-things-thread", () => {
                var branch_str = get_stdout (new string[] { "git", "branch" }, this.directory);
                var branches = branch_str.split ("\n");
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    this.branches.model.remove_all ();
                    foreach (var b in branches) {
                        if (b == null || b.length < 2)
                            continue;
                        var br = new Branch ();
                        br.dir = this.directory;
                        br.is_active = b.has_prefix ("*");
                        br.name = b.substring (2).strip ();
                        if (br.name != "")
                            this.branches.model.append (br);
                    }
                    return Source.REMOVE;
                });
                var remotes_str = get_stdout (new string[] { "git", "remote", "-v" }, this.directory);
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    var remotes = remotes_str.split ("\n");
                    this.remotes.model.remove_all ();
                    var vals = new Gee.HashSet<string> (a => str_hash (a), (a, b) => a == b);
                    foreach (var r in remotes) {
                        if (r == null || r.length < 2)
                            continue;
                        var remote = new Remote ();
                        var parts = r.split ("\t");
                        remote.name = parts[0];
                        if (remote.name in vals)
                            continue;
                        vals.add (remote.name);
                        remote.uri = parts[1].split (" ")[0];
                        remote.dir = this.directory;
                        this.remotes.model.append (remote);
                    }
                    return Source.REMOVE;
                });
                var commits_str = get_stdout (new string[] { "git", "log", "--format=%h||%an||%ae||%at||%cn||%ce||%s" }, this.directory);
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    var commits = commits_str.split ("\n");
                    this.commits.model.remove_all ();
                    var n = 0;
                    foreach (var c in commits) {
                        if (n == 300)
                            break;
                        if (c == null || c.length < 2)
                            continue;
                        var commit = new Commit ();
                        var parts = c.split ("||", 7);
                        commit.hash = parts[0];
                        commit.author = new Person (parts[1], parts[2]);
                        commit.time = new GLib.DateTime.from_unix_local (int64.parse (parts[3]));
                        commit.committer = new Person (parts[4], parts[5]);
                        commit.message_first_line = parts[6];
                        commit.dir = this.directory;
                        this.commits.model.append (commit);
                        n++;
                    }
                    return Source.REMOVE;
                });
            });
        }
    }

    public class CommitWindow : Adw.Window {
        private GtkSource.View view;
        private CommitExploreView explore;
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
            var provider = new Gtk.CssProvider ();
            provider.load_from_data ("textview{font-family: Monospace;}".data);
            this.view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            var sc = new Gtk.ScrolledWindow ();
            sc.child = this.view;
            var stack = new Adw.ViewStack ();
            this.explore = new CommitExploreView (c);
            stack.add_titled (sc, "diff", "Diff");
            stack.add_titled (this.explore, "browse", "Browse tree at %s".printf (c.hash));
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
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    var file_list = get_stdout (new string[] { "git", "ls-tree", c.hash, "-r" }, c.dir);
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
            });
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
            buf.style_scheme = GtkSource.StyleSchemeManager.get_default ().get_scheme ("adwaita-dark");
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
                critical ("Getting %s (%s)", s, b);
                var lang = GtkSource.LanguageManager.get_default ().guess_language (b, null);
                critical ("%s", lang.id);
                ((GtkSource.Buffer) this.view.buffer).language = lang;
                this.view.buffer.text = content;
            });
            l.add_controller (gc);
            this.left_side.append (l);
        }
    }

    static string get_stdout (string[] args, string dir) throws SpawnError {
        string sout, serr;
        int status;
        Process.spawn_sync (dir, args, Environ.get (), SpawnFlags.SEARCH_PATH, null, out sout, out serr, out status);
        if (status != 0)
            critical ("%s:\n%s", string.join (" ", args), serr);
        return sout;
    }

    public class Person : GLib.Object {
        public string name { get; set; }
        public string email { get; set; }

        public Person (string n, string e) {
            this.name = n;
            this.email = e;
        }
    }

    public class Item : GLib.Object {
        public string dir { get; set; }
    }

    public class Remote : Item {
        public string name { get; set; }
        public string uri { get; set; }
    }

    public class Branch : Item {
        public string name { get; set; }
        public bool is_active { get; set; }
    }

    public class Commit : Item {
        public string hash { get; set; }
        public string message_first_line { get; set; }
        public GLib.DateTime time { get; set; }
        public Person author { get; set; }
        public Person committer { get; set; }
    }

    public class ListView<T>: Gtk.Box {
        internal GLib.ListStore model;
        private Gtk.ListBox view;

        public ListView (string dir, Gtk.ListBoxCreateWidgetFunc func) {
            this.orientation = Gtk.Orientation.VERTICAL;
            this.model = new GLib.ListStore (typeof (T));
            this.view = new Gtk.ListBox ();
            this.view.bind_model (this.model, func);
            this.append (this.view);
        }
    }
}

public void peas_register_types (TypeModule module) {
    var r = gitgui_get_resource ();
    GLib.resources_register (r);
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (GitGui.WorkspaceAddin));
}
