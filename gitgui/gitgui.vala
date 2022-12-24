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

// TODO: Several files
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
            create_repo_button.clicked.connect (() => {
                get_stdout (new string[] { "git", "init" }, this.directory);
            });
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
        private GeneralActions actions;

        public Action (string dir) {
            this.directory = dir;
            var b = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            var stack = new Adw.ViewStack ();
            this.actions = new GeneralActions (dir);
            this.actions.trigger_reload.connect (() => {
                this.reload ();
            });
            this.remotes = new ListView<Remote> (dir, create_remote);
            this.branches = new ListView<Branch> (dir, create_branch);
            this.commits = new ListView<Commit> (dir, create_commit);
            this.add (stack, this.actions, "general", "General", "general-properties-symbolic");
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
            sc.hscrollbar_policy = Gtk.PolicyType.NEVER;
            stack.add_titled (sc, id, title).icon_name = icon;
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
                        if (br.is_active) {
                            this.actions.branch.title = "Branch: " + br.name;
                        }
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

    public class GeneralActions : Gtk.Box {
        private string directory;
        internal Adw.ActionRow branch;
        internal Gtk.Button stash;
        internal Gtk.Button clean_all;
        internal Gtk.Button clean_ignored;
        internal Gtk.Button commit;

        public GeneralActions (string dir) {
            this.directory = dir;
            this.orientation = Gtk.Orientation.VERTICAL;
            this.spacing = 2;
            this.branch = new Adw.ActionRow ();
            this.branch.title = "Branch: ||";
            this.commit = new Gtk.Button.with_label ("Commit");
            this.commit.get_style_context ().add_class ("suggested-action");
            this.append (this.branch);
            this.append (this.commit);
            this.stash = this.gen_button ("Stash changes", "git stash", "Do you really want to stash the changes?", "git||stash");
            this.clean_all = this.gen_button ("Clean all", "git clean -dfx", "Do you really want to clean the working dir?", "git||clean||-dfx");
            this.clean_ignored = this.gen_button ("Clean all ignored files", "git clean -df", "Do you really want to remove all ignored files?", "git||clean||-df");
            var b = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
            b.append (this.stash);
            b.append (this.clean_all);
            b.append (this.clean_ignored);
            this.append (b);
            new Thread<void> ("commit-status", () => {
                while (true) {
                    var o = get_stdout (new string[] { "git", "status", "-s" }, this.directory);
                    Idle.add_full (Priority.LOW, () => {
                        this.commit.sensitive = o.strip ().length != 0;
                        return Source.REMOVE;
                    });
                    Posix.sleep (5);
                }
            });
            this.commit.clicked.connect (() => {
                var o = get_stdout (new string[] { "git", "status", "-s" }, this.directory).strip ();
                var v = new CommitDialog (dir, o);
                v.modal = true;
                v.set_transient_for ((Gtk.Window) this.root);
                v.committed.connect (() => {
                    this.trigger_reload ();
                });
                v.present ();
            });
        }

        private Gtk.Button gen_button (string s, string title, string msg, string cmd) {
            var ret = new Gtk.Button.with_label (s);
            ret.clicked.connect (() => {
                var a = cmd.split ("||");
                var d = this.directory;
                var m = new Adw.MessageDialog (null, title, msg);
                m.add_response ("yes", "Yes");
                m.add_response ("no", "No");
                m.set_response_appearance ("yes", Adw.ResponseAppearance.DESTRUCTIVE);
                m.default_response = "no";
                m.response.connect (s => {
                    if (s == "yes")
                        get_stdout (a, d);
                });
                m.present ();
            });
            ret.hexpand = true;
            return ret;
        }

        internal signal void trigger_reload ();
    }

    public class CommitSelectComponent : Gtk.Box {
        private Gtk.CheckButton[] check_marks;
        private string[] paths;

        public CommitSelectComponent (string o) {
            this.orientation = Gtk.Orientation.VERTICAL;
            this.spacing = 4;
            var b1 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            var add_all = new Gtk.Button.with_label ("Select all");
            add_all.clicked.connect (() => {
                // For n files, that is n^2 iterations
                foreach (var a in this.check_marks)
                    a.active = true;
            });
            var unadd_all = new Gtk.Button.with_label ("Unselect all");
            unadd_all.clicked.connect (() => {
                // For n files, that is n^2 iterations
                foreach (var a in this.check_marks)
                    a.active = false;
            });
            b1.append (add_all);
            b1.append (unadd_all);
            this.append (b1);
            foreach (var l in o.split ("\n")) {
                if (l == null || l.length < 2)
                    continue;
                // TODO: Add icon based on type
                // var type = l.substring (0, 3).strip ();
                var path = l.strip ().split (" ", 2)[1];
                var row = new Adw.ActionRow ();
                row.title = path;
                var c = new Gtk.CheckButton ();
                c.get_style_context ().add_class ("round");
                this.check_marks += c;
                this.paths += path;
                c.active = true;
                c.toggled.connect (() => {
                    var yes = false;
                    foreach (var c1 in this.check_marks) {
                        yes |= c1.active;
                    }
                    this.can_continue (yes);
                });
                row.add_prefix (c);
                this.append (row);
            }
        }

        internal string[] paths_to_add () {
            var ret = new string[0];
            for (var i = 0; i < this.paths.length; i++)
                if (this.check_marks[i].active)
                    ret += this.paths[i];
            return ret;
        }

        internal signal void can_continue (bool b);
    }

    public class CommitDialog : Adw.Window {
        public CommitDialog (string dir, string o) {
            var ekc = new Gtk.EventControllerKey ();
            ekc.key_released.connect ((v, c, s) => {
                if (v == Gdk.Key.Escape)
                    this.close ();
            });
            ((Gtk.Widget) this).add_controller (ekc);
            var stack = new Gtk.Stack ();
            var select_component = new CommitSelectComponent (o);
            select_component.vexpand = true;
            var sc = new Gtk.ScrolledWindow ();
            sc.child = select_component;
            sc.vexpand = true;
            var clamp = new Adw.Clamp ();
            clamp.maximum_size = 600;
            clamp.child = sc;
            clamp.vexpand = true;
            {
                var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
                var header = new Adw.HeaderBar ();
                header.show_end_title_buttons = false;
                var title = new Adw.WindowTitle ("Commit", "Select files");
                header.title_widget = title;
                var cancel = new Gtk.Button.with_label ("Cancel");
                cancel.clicked.connect (() => {
                    this.close ();
                });
                header.pack_start (cancel);
                var cont = new Gtk.Button.with_label ("Continue");
                select_component.can_continue.connect (a => cont.sensitive = a);
                cont.clicked.connect (() => {
                    stack.visible_child_name = "write";
                });
                cont.get_style_context ().add_class ("suggested-action");
                header.pack_end (cont);
                box.append (header);
                box.append (clamp);
                stack.add_named (box, "list");
            }
            {
                var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
                var header = new Adw.HeaderBar ();
                header.show_end_title_buttons = false;
                var title = new Adw.WindowTitle ("Commit", "Write commit message");
                header.title_widget = title;
                var cancel = new Gtk.Button.from_icon_name ("left-symbolic");
                cancel.clicked.connect (() => {
                    stack.visible_child_name = "list";
                });
                header.pack_start (cancel);
                var child = new Gtk.TextView ();
                var cont = new Gtk.Button.with_label ("Commit");
                cont.clicked.connect (() => {
                    var paths = select_component.paths_to_add ();
                    foreach (var p in paths)
                        get_stdout (new string[] { "git", "add", p }, dir);
                    get_stdout (new string[] { "git", "commit", "-m", child.buffer.text.strip () }, dir);
                    this.committed ();
                    this.close ();
                });
                child.buffer.changed.connect (() => {
                    cont.sensitive = child.buffer.text.strip () != "";
                });
                ekc = new Gtk.EventControllerKey ();
                ekc.key_released.connect ((v, c, s) => {
                    if (v == Gdk.Key.decimalpoint && (s & Gdk.ModifierType.CONTROL_MASK) != 0)
                        child.insert_emoji ();
                });
                child.add_controller (ekc);
                cont.get_style_context ().add_class ("suggested-action");
                cont.sensitive = false;
                header.pack_end (cont);
                box.append (header);
                child.hexpand = true;
                child.vexpand = true;
                var provider = new Gtk.CssProvider ();
                provider.load_from_data ("textview{font-family: Monospace;}".data);
                child.input_hints = Gtk.InputHints.EMOJI | Gtk.InputHints.SPELLCHECK | Gtk.InputHints.WORD_COMPLETION | Gtk.InputHints.UPPERCASE_SENTENCES;
                child.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                sc = new Gtk.ScrolledWindow ();
                sc.child = child;
                child.buffer.changed.connect (() => {
                    cont.sensitive = child.buffer.text.strip () != "";
                });
                box.append (sc);
                stack.add_named (box, "write");
            }
            stack.visible_child_name = "list";
            this.content = stack;
            this.resizable = false;
            this.set_size_request (640, 480);
        }

        internal signal void committed ();
    }

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

    static string get_stdout (string[] args, string dir) {
        try {
            string sout, serr;
            int status;
            Process.spawn_sync (dir, args, Environ.get (), SpawnFlags.SEARCH_PATH, null, out sout, out serr, out status);
            if (status != 0) {
                critical ("Command failed:\n%s", serr);
                return "";
            }
            return sout;
        } catch (SpawnError e) {
            critical ("%s: %s", string.join (" ", args), e.message);
            return "";
        }
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
    obj.register_extension_type (typeof (Ide.EditorPageAddin), typeof (GitGui.GitEditorPageAddin));
}
