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
        this.thread = new Thread<void>(".git/config watcher", () => {
            var ifd = Linux.inotify_init ();
            critical ("FD: %d", ifd);
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
                var fd = Linux.inotify_add_watch (ifd, dir + "/.git/", Linux.InotifyMaskFlags.DELETE_SELF | Linux.InotifyMaskFlags.CREATE | Linux.InotifyMaskFlags.MODIFY | Linux.InotifyMaskFlags.DELETE);
                while (fd > 0) {
                    Linux.InotifyEvent evt = {0};
                    Posix.read (ifd, &evt, sizeof (Linux.InotifyEvent) + Posix.Limits.NAME_MAX + 1);
                    if (evt.len > 0) {
                        info ("Event: %s", (string)evt.name);
                        if ((evt.mask & Linux.InotifyMaskFlags.CREATE) != 0) {
                            if (Posix.stat (full_path, out buf) == 0 && buf.st_ino == ino && buf.st_mtime > mtime) {
                                this.created_config ();
                                mtime = buf.st_mtime;
                            }
                        } else if ((evt.mask & Linux.InotifyMaskFlags.DELETE) != 0) {
                            if (Posix.stat (full_path, out buf) != 0) {
                                this.deleted_config ();
                                break;
                            }
                        } else if ((evt.mask & Linux.InotifyMaskFlags.MODIFY) != 0) {
                            if (Posix.stat (full_path, out buf) == 0 && buf.st_ino == ino && buf.st_mtime > mtime) {
                                this.edited_config ();
                                mtime = buf.st_mtime;
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

        this.action = new GitGuiAction (dir);
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
        critical ("Created config");
        if (this.stack.visible_child_name == "create") {
            this.stack.visible_child = this.action;
        }
        this.action.reload ();
    }

    internal void deleted_config () {
        critical ("Deleted config");
        if (this.stack.visible_child_name == "action") {
            this.stack.visible_child_name = "create";
        }
        this.action.reload ();
    }

    internal void edited_config () {
        critical ("Edited config");
        if (this.stack.visible_child_name == "create") {
            this.stack.visible_child = this.action;
        }
        this.action.reload ();
    }
}

public class GitGuiAction : Gtk.Box {
    private string directory;

    public GitGuiAction (string dir) {
        this.directory = dir;
        this.orientation =  Gtk.Orientation.VERTICAL;
    }

    public void reload () {

    }
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (GitGuiWorkspaceAddin));
}
