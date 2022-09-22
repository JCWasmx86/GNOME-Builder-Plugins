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
	public SqlConnectionsView () {
		this.orientation = Gtk.Orientation.HORIZONTAL;
		this.spacing = 2;
		this.realize.connect (() => {
			this.build_gui ();
			this.load_data ();
		});
	}
	void build_gui () {
		var expander = new Gtk.Expander ("Create SQL-Connection");
		this.data = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
		expander.child = new SqlConnectionCreator (this.data);
		this.append (expander);
		var sc = new Gtk.ScrolledWindow ();
		sc.child = data;
		this.append (sc);
	}
	void load_data () {

	}
}
public class SqlConnectionCreator : Gtk.Box {
	private Gtk.Box append_here;
	private Adw.EntryRow alias;
	private Gtk.Expander expander;
	private Gtk.Box buttons;
	private SqlConnectionSubCreator pqsql;
	private SqlConnectionSubCreator mysql;
	private SqlConnectionSubCreator sqlite;
	public SqlConnectionCreator (Gtk.Box append_here) {
		this.append_here = append_here;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.spacing = 2;
		this.pqsql = new PostgresConnectionCreator ();
		this.mysql = new MySQLConnectionCreator ();
		this.sqlite = new SQLiteConnectionCreator ();
		this.alias = new Adw.EntryRow ();
		this.alias.title = "Alias";
		this.append (this.alias);
		var tabview = new Adw.TabView ();
		var page = tabview.add_page (this.pqsql, null);
		page.title = "PostgreSQL";
		page = tabview.add_page (this.mysql, null);
		page.title = "MySQL";
		page = tabview.add_page (this.sqlite, null);
		page.title = "SQLite";
		var tabbar = new Adw.TabBar ();
		tabbar.view = tabview;
		tabview.close_page.connect (() => {
			return true;
		});
		this.append (tabbar);
		this.append (tabview);
		this.expander = new Gtk.Expander ("SSH-Authentication");
		this.append (this.expander);
		this.buttons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
		var clear_all = new Gtk.Button.with_label ("Clear");
		clear_all.get_style_context ().add_class ("destructive-action");
		this.buttons.append (clear_all);
		var save = new Gtk.Button.with_label ("Save");
		save.get_style_context ().add_class ("suggested-action");
		this.buttons.append (save);
		this.buttons.halign = Gtk.Align.END;
		this.append (this.buttons);
	}

}
public abstract class SqlConnectionSubCreator : Gtk.Box {

}

public class SQLiteConnectionCreator : SqlConnectionSubCreator {
	public SQLiteConnectionCreator () {
		this.spacing = 2;
		this.orientation = Gtk.Orientation.VERTICAL;
	}
}

public class MySQLConnectionCreator : SqlConnectionSubCreator {
	public MySQLConnectionCreator () {
		this.spacing = 2;
		this.orientation = Gtk.Orientation.VERTICAL;
	}
}

public class PostgresConnectionCreator : SqlConnectionSubCreator {
	public PostgresConnectionCreator () {
		this.spacing = 2;
		this.orientation = Gtk.Orientation.VERTICAL;
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

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (SqlConnectionsWorkspaceAddin));
}