/* sqlconnections.vala
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

public class SqlConnectionsWorkspaceAddin : GLib.Object, Ide.WorkspaceAddin {
	public void page_changed (Ide.Page? page) {
	}

	public void unload (Ide.Workspace workspace) {
	}

	public void load (Ide.Workspace workspace) {
		var pos = new Panel.Position ();
		pos.set_area (Panel.Area.BOTTOM);
		pos.set_depth (2);
		workspace.add_pane (new SqlConnectionsPane (), pos);
	}
}
public class SqlConnectionsPane : Ide.Pane {
	public SqlConnectionsPane () {
		this.name = "SQL-Connections Manager";
		this.icon_name = "text-sql-symbolic";
		this.realize.connect (() => {
			this.set_child (new SqlConnectionsView ());
		});
	}
}
public class SqlConnectionsView : Gtk.Box {
	private Gtk.Box data;
	private Gtk.Box top;

	private Gtk.Button add_button;
	public SqlConnectionsView () {
		this.orientation = Gtk.Orientation.HORIZONTAL;
		this.spacing = 2;
		this.realize.connect (() => {
			this.build_gui ();
			this.load_data ();
		});
	}
	void build_gui () {
		this.add_button = new Gtk.Button.from_icon_name ("list-add-symbolic");
		this.add_button.tooltip_text = "Add Connection";
		this.top = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
		this.top.append (this.add_button);
		this.append (this.top);
		this.data = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
		var sc = new Gtk.ScrolledWindow ();
		sc.child = data;
		this.append (sc);
	}
	void load_data () {

	}
}
public class SqlConnectionEntry : Adw.ActionRow {
	public string alias { get; set; }
	public SqlConnectionEntry() {
		var btn = new Gtk.Button.from_icon_name ("small-x-symbolic");
		this.add_prefix (btn);
	}
	public virtual void finish (string alias) {
		this.title = alias;
	}
}
public class SqliteConnectionEntry : SqlConnectionEntry {

}

public abstract class SSHSqlConnectionEntry : SqlConnectionEntry {
	public string? host { get; set; default = ""; }
	public int? port;
	construct {
		this.port = 22;
	}
	public string? user { get; set; }
	public string? private_key_path { get; set; }
	public string? passphrase { get; set; }

	public abstract string build_connection_url ();

	public override void finish (string alias) {
		base.finish (alias);
		if (this.host != null) {
			this.subtitle = this.build_connection_url ();
		}
	}
}

public class MySqlConnectionEntry : SSHSqlConnectionEntry {
	public override string build_connection_url () {
		return "";
	}
}

public class PostgresConnectionEntry : SSHSqlConnectionEntry {
	public override string build_connection_url () {
		return "";
	}
}

// SqlConnectionCreator

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (SqlConnectionsWorkspaceAddin));
}