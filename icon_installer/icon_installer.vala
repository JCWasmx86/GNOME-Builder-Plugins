/* icon_installer.vala
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
[CCode (cname = "icon_installer_get_resource")]
public static extern Resource icon_installer_get_resource ();

public class IconInstallerWorkspaceAddin : GLib.Object, Ide.WorkspaceAddin {
	public void page_changed (Ide.Page? page) {
	}

	public void unload (Ide.Workspace workspace) {
	}

	public void load (Ide.Workspace workspace) {
		var pos = new Panel.Position ();
		pos.set_area (Panel.Area.BOTTOM);
		pos.set_depth (2);
		workspace.add_pane (new IconInstallerPane (workspace.context.workdir), pos);
	}
}
public class IconInstallerPane : Ide.Pane {
	public IconInstallerPane (File file) {
		this.realize.connect (() => {
			Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).add_resource_path ("/plugins/icon_installer/icons");
			this.icon_name = "grid-symbolic";
			this.name = "Icon Installer";
			this.set_child (new IconInstallerView (file));
		});
	}
}

public class IconInstallerImage : Gtk.Box {
	public Gtk.Image image;
	private string[] strings;
	private string icon_name;

	public IconInstallerImage (string str, Json.Array arr, File workdir) {
		this.icon_name = str.substring (5);
		this.orientation = Gtk.Orientation.VERTICAL;
		this.spacing = 2;
		var img = new Gtk.Image.from_icon_name (str);
		img.pixel_size = 32;
		img.tooltip_text = str.substring (5);
		this.append (img);
		var ctrl = new Gtk.GestureClick ();
		ctrl.pressed.connect ((n, x, y) => {
			ctrl.propagation_phase = Gtk.PropagationPhase.BUBBLE;
			File? path;
			try {
				path = this.find_path_to_gresource (workdir);
			} catch (Error e) {
				error ("OOPS: %s", e.message);
			}
			if (path == null) {
				path = workdir.get_child ("data").get_child ("resources.gresource.xml");
			}
			Idle.add (() => {
				var window = new Gtk.Dialog ();
				window.title = "Install icon %s".printf (str);
				window.transient_for = (Gtk.Window) this.root;
				var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
				var image = new Gtk.Image.from_icon_name (str);
				image.pixel_size = 96;
				box.append (image);
				var resource_file_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
				var lbl = new Gtk.Label ("Adding reference to %s".printf (workdir.get_relative_path (path)));
				var save_file_lbl = new Gtk.Label ("Saving SVG to %s".printf (workdir.get_relative_path (resolve_icon_path (path))));
				save_file_lbl.ellipsize = Pango.EllipsizeMode.MIDDLE;
				var change_me = new Gtk.Button.with_label ("Change it");
				resource_file_box.append (lbl);
				resource_file_box.append (change_me);
				change_me.clicked.connect (() => {
					var dialog = new Gtk.FileChooserDialog ("Select resource file", window, Gtk.FileChooserAction.OPEN, "Cancel", Gtk.ResponseType.CANCEL, "Select", Gtk.ResponseType.OK, null);
					var ff = new Gtk.FileFilter ();
					ff.name = "*.gresource.xml";
					ff.add_pattern ("*.gresource.xml");
					try {
						dialog.set_current_folder (workdir);
					} catch (Error e) {
						critical ("%s", e.message);
					}
					dialog.add_filter (ff);
					dialog.present ();
					dialog.response.connect (a => {
						if (a == Gtk.ResponseType.OK) {
							lbl.label = "Adding reference to %s".printf (workdir.get_relative_path (dialog.get_file ()));
							path = dialog.get_file ();
							save_file_lbl = new Gtk.Label ("Saving SVG to %s".printf (workdir.get_relative_path (resolve_icon_path (path))));
						}
						dialog.destroy ();
					});
				});
				box.append (resource_file_box);
				box.append (save_file_lbl);
				var btn_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
				var ok = new Gtk.Button.with_label ("Save");
				ok.hexpand = true;
				ok.get_style_context ().add_class ("suggested-action");
				ok.clicked.connect (() => {
					try {
						apply_changes (path, resolve_icon_path (path));
					} catch (Error e) {
						critical ("%s", e.message);
					}
					window.destroy ();
				});
				btn_box.append (ok);
				var cancel = new Gtk.Button.with_label ("Cancel");
				cancel.hexpand = true;
				btn_box.append (cancel);
				cancel.clicked.connect (() => {
					window.destroy ();
				});
				box.append (btn_box);
				btn_box.set_hexpand (true);
				window.child = box;
				window.modal = true;
				window.present ();
				window.resizable = false;
				return Source.REMOVE;
			});
		});
		img.add_controller (ctrl);
		this.image = img;
		var strs = new string[0];
		for (var i = 0; i < arr.get_length (); i++)
			strs += arr.get_string_element (i);
		this.strings = strs;
	}

	void apply_changes (File gresource, File svg) throws Error {
		var g_parent = gresource.get_parent ();
		try {
			g_parent.make_directory_with_parents ();
		} catch (Error e) {
			// Ignore, as it could just be that it already exists
		}
		var svg_parent = svg.get_parent ();
		try {
			svg_parent.make_directory_with_parents ();
		} catch (Error e) {
			// Ignore, as it could just be that it already exists
		}
		if (!svg.query_exists ()) {
			FileUtils.set_contents (svg.get_path (), (string) GLib.resources_lookup_data ("/plugins/icon_installer/icons/scalable/actions/show-" + this.icon_name + ".svg", GLib.ResourceLookupFlags.NONE).get_data ());
		}

		if (gresource.query_exists ()) {
			string data = "";
			FileUtils.get_contents (gresource.get_path (), out data);
			var new_str = new StringBuilder ();
			var set_it = false;
			foreach (var s in data.split ("\n")) {
				new_str.append (s).append ("\n");
				if (s.strip ().has_prefix ("<file") && !set_it) {
					var indent = s.substring (0, s.length - s.chug ().length);
					var append_it = indent + "<file preprocess=\"xml-stripblanks\">" + gresource.get_parent ().get_relative_path (svg) + "</file>\n";
					set_it = true;
					new_str.append (append_it);
				}
			}
			FileUtils.set_contents (gresource.get_path (), new_str.str);
		} else {
			var example_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gresources>\n  <gresource prefix=\"/org/gtk/Example\">\n    <file preprocess=\"xml-stripblanks\">%s</file>\n  </gresource>\n<gresource>\n";
			FileUtils.set_contents (gresource.get_path (), example_xml.printf (gresource.get_parent ().get_relative_path (svg)));
		}
	}

	File resolve_icon_path (File path) {
		return path.get_parent ().get_child ("icons").get_child ("scalable").get_child ("actions").get_child (this.icon_name + ".svg");
	}

	File ? find_path_to_gresource (File curr_dir) throws Error {
		var children = curr_dir.enumerate_children ("standard::*", GLib.FileQueryInfoFlags.NONE);
		FileInfo child;
		while ((child = children.next_file ()) != null) {
			if (child.get_file_type () == FileType.REGULAR && child.get_name ().has_suffix (".gresource.xml")) {
				return curr_dir.get_child (child.get_name ());
			} else if (child.get_file_type () == FileType.DIRECTORY) {
				var f = find_path_to_gresource (curr_dir.get_child (child.get_name ()));
				if (f != null)
					return f;
			}
		}
		return null;
	}

	public bool match (string[] terms) {
		foreach (var term in terms) {
			if (term == this.icon_name || (this.icon_name.has_prefix (term) && term.length > 3))
				return true;
			foreach (var alias in this.strings) {
				if (alias == term || alias.contains (term)) {
					return true;
				}
			}
		}
		return false;
	}
}

public class IconInstallerView : Gtk.Box {
	public IconInstallerView (File file) {
		this.realize.connect (() => {
			try {
				this.load_data (file);
			} catch (Error e) {
				error ("%s", e.message);
			}
		});
	}

	public void load_data (File file) throws GLib.Error {
		new Thread<void> ("loader", () => {
			var bar = new Gtk.ProgressBar ();
			bar.text = "Loading icons…";
			bar.show_text = true;
			Idle.add (() => {
				this.append (bar);
				this.orientation = Gtk.Orientation.VERTICAL;
				this.spacing = 2;
				this.vexpand = true;
				return Source.REMOVE;
			});
			Bytes strings;
			Bytes json;
			try {
				strings = icon_installer_get_resource ().ref ().lookup_data ("/plugins/icon_installer/icons.txt", ResourceLookupFlags.NONE);
				json = icon_installer_get_resource ().ref ().lookup_data ("/plugins/icon_installer/icons.json", ResourceLookupFlags.NONE);
			} catch (Error e) {
				error ("OOPS: %s", e.message);
			}
			var p = new Json.Parser ();
			try {
				p.load_from_data ((string) json.get_data ());
			} catch (Error e) {
				error ("OOPS: %s", e.message);
			}
			var root = p.get_root ().get_object ();
			var s = (string) (strings.get_data ());
			var strs = s.split ("\n");
			var box = new Gtk.FlowBox ();
			Idle.add (() => {
				var sc = new Gtk.ScrolledWindow ();
				sc.child = box;
				sc.vexpand = true;
				this.append (sc);
				return Source.REMOVE;
			});
			var list = new Gee.ArrayList<IconInstallerImage> ();
			var i = 0;
			foreach (var str in strs) {
				if (str.strip () == "")
					break;
				Idle.add (() => {
					var member = str.substring (5).replace ("-symbolic", "");
					Json.Array arr = new Json.Array ();
					if (root.has_member (member)) {
						arr = root.get_array_member (member);
					}
					var img = new IconInstallerImage (str, arr, file);
					list.add (img);
					box.append (img);
					bar.fraction = ((double) i++) / strs.length;
					return Source.REMOVE;
				});
				Thread.usleep (50);
			}
			Idle.add (() => {
				var search_box = new Gtk.Entry ();
				search_box.tooltip_text = "Search for icon";
				search_box.changed.connect (() => {
					var text = search_box.text;
					if (text.strip () == "") {
						foreach (var item in list) {
							item.visible = true;
							item.parent.visible = true;
						}
					} else {
						var terms = text.split (" ");
						foreach (var item in list) {
							item.visible = item.match (terms);
							item.parent.visible = item.visible;
						}
					}
				});
				this.prepend (search_box);
				this.remove (bar);
				return Source.REMOVE;
			});
		});
	}
}


public void peas_register_types (TypeModule module) {
	var r = icon_installer_get_resource ();
	GLib.resources_register (r);
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (IconInstallerWorkspaceAddin));
}