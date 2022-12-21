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
public class GitGuiWorkspaceAddin : GLib.Object, Ide.WorkspaceAddin {

    public void page_changed (Ide.Page? page) {
    }

    public void unload (Ide.Workspace workspace) {
    }

    public void load (Ide.Workspace workspace) {
        var pos = new Panel.Position ();
        pos.set_area (Panel.Area.START);
        pos.set_row (0);
        pos.set_depth (3);
        workspace.add_pane (new GitGuiPanel (workspace.context.workdir.get_path ()), pos);
    }
}

public class GitGuiPanel : Ide.Pane {
    private string directory;
    private GitGuiView view;
    construct {
        this.title = "Git";
        this.icon_name = "branch-symbolic";
    }

    public GitGuiPanel (string dir) {
        Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).add_resource_path ("/plugins/gitgui/icons");
        this.directory = dir;
        this.view = new GitGuiView (dir);
        this.realize.connect (() => {
            this.set_child (view);
        });
    }
}

public class GitGuiView : Adw.Bin {
    private string directory;
    private Gtk.Stack stack;
    private GitGuiAction action;
    private Thread<void> thread;

    public GitGuiView (string dir) {
        this.directory = dir;
        this.stack = new Gtk.Stack ();
        this.child = this.stack;
        this.action = new GitGuiAction (dir);
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

public class GitGuiAction : Adw.Bin {
    private string directory;
    private GitGuiListView<GitGuiRemote> remotes;
    private GitGuiListView<GitGuiBranch> branches;
    private GitGuiListView<GitGuiCommit> commits;

    // TODO: No, better use models+listviews+e.g. search providers

    public GitGuiAction (string dir) {
        this.directory = dir;
        var b = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        var stack = new Adw.ViewStack ();
        this.remotes = new GitGuiListView<GitGuiRemote> (dir, create_remote);
        this.branches = new GitGuiListView<GitGuiBranch> (dir, create_branch);
        this.commits = new GitGuiListView<GitGuiCommit> (dir, create_commit);
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
        row.title = Markup.escape_text (((GitGuiRemote)obj).name);
        row.subtitle = Markup.escape_text (((GitGuiRemote)obj).uri);
        return row;
    }

    private static Gtk.Widget create_branch (Object obj) {
        var row = new Adw.ActionRow ();
        row.title = Markup.escape_text (((GitGuiBranch)obj).name);
        var is_active = ((GitGuiBranch)obj).is_active;
        if (is_active)
            row.subtitle = "Current branch";
        return row;
    }

    private static Gtk.Widget create_commit (Object obj) {
        var row = new Adw.ActionRow ();
        row.title = Markup.escape_text (((GitGuiCommit)obj).message_first_line);
        row.subtitle = Markup.escape_text (((GitGuiCommit)obj).hash);
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
        row.add_suffix (more_button);
        return row;
    }

    private static string get_stdout (string[] args, string dir) throws SpawnError {
        string sout, serr;
        int status;
        Process.spawn_sync (dir, args, Environ.get (), SpawnFlags.SEARCH_PATH, null, out sout, out serr, out status);
        if (status != 0)
            critical ("%s:\n%s", string.join (" ", args), serr);
        return sout;
    }

    public void reload () {
        new Thread<void> ("git-update-things-thread", () => {
            var branch_str = get_stdout (new string[] {"git", "branch"}, this.directory);
            var branches = branch_str.split ("\n");
            Idle.add_full (Priority.HIGH_IDLE, () => {
                this.branches.model.remove_all ();
                foreach (var b in branches) {
                    if (b == null || b.length < 2)
                        continue;
                    var br = new GitGuiBranch ();
                    br.is_active = b.has_prefix ("*");
                    br.name = b.substring (2).strip ();
                    if (br.name != "")
                        this.branches.model.append (br);
                }
                return Source.REMOVE;
            });
            var remotes_str = get_stdout (new string[] {"git", "remote", "-v"}, this.directory);
            Idle.add_full (Priority.HIGH_IDLE, () => {
                var remotes = remotes_str.split ("\n");
                this.remotes.model.remove_all ();
                var vals = new Gee.HashSet<string> (a => str_hash (a), (a,b) => a == b);
                foreach (var r in remotes) {
                    if (r == null || r.length < 2)
                        continue;
                    var remote = new GitGuiRemote ();
                    var parts = r.split ("\t");
                    remote.name = parts[0];
                    if (remote.name in vals)
                        continue;
                    vals.add (remote.name);
                    remote.uri = parts[1].split (" ")[0];
                    this.remotes.model.append (remote);
                }
                return Source.REMOVE;
            });
            var commits_str = get_stdout (new string[] {"git", "log", "--format=%h||%an||%ae||%at||%cn||%ce||%s"}, this.directory);
            Idle.add_full (Priority.HIGH_IDLE, () => {
                var commits = commits_str.split ("\n");
                this.commits.model.remove_all ();
                var n = 0;
                foreach (var c in commits) {
                    if (n == 300)
                        break;
                    if (c == null || c.length < 2)
                        continue;
                    var commit = new GitGuiCommit ();
                    var parts = c.split("||", 7);
                    commit.hash = parts[0];
                    commit.author = new GitGuiPerson (parts[1], parts[2]);
                    commit.time = new GLib.DateTime.from_unix_local (int64.parse (parts[3]));
                    commit.committer = new GitGuiPerson (parts[4], parts[5]);
                    commit.message_first_line = parts[6];
                    this.commits.model.append (commit);
                    n++;
                }
                return Source.REMOVE;
            });
        });
    }
}

public class GitGuiPerson : GLib.Object {
    public string name { get; set; }
    public string email { get; set; }

    public GitGuiPerson (string n, string e) {
        this.name = n;
        this.email = e;
    }
}

public class GitGuiItem : GLib.Object {
    public string dir { get; set; }
}

public class GitGuiRemote : GitGuiItem {
    public string name { get; set; }
    public string uri { get; set; }
}

public class GitGuiBranch : GitGuiItem {
    public string name { get; set; }
    public bool is_active { get; set; }
}

public class GitGuiCommit : GitGuiItem {
    public string hash { get; set; }
    public string message_first_line { get; set; }
    public GLib.DateTime time { get; set; }
    public GitGuiPerson author { get; set; }
    public GitGuiPerson committer { get; set; }
}

public class GitGuiListView<T> : Gtk.Box {
    internal GLib.ListStore model;
    private Gtk.ListBox view;

    public GitGuiListView (string dir, Gtk.ListBoxCreateWidgetFunc func) {
        this.orientation = Gtk.Orientation.VERTICAL;
        this.model = new GLib.ListStore (typeof (T));
        this.view = new Gtk.ListBox ();
        this.view.bind_model (this.model, func);
        this.append (this.view);
    }
}

public class GitGuiRemoteView : Gtk.Box {
    public GitGuiRemoteView (string dir) {
    }
}

public class GitGuiBranchView : Gtk.Box {
    public GitGuiBranchView (string dir) {
    }
}

public class GitGuiCommitView : Gtk.Box {
    public GitGuiCommitView (string dir) {
    }
}

public void peas_register_types (TypeModule module) {
    var r = gitgui_get_resource ();
	GLib.resources_register (r);
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (GitGuiWorkspaceAddin));
}
