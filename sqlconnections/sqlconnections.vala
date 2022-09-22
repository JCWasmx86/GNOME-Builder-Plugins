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
	private GLib.GenericArray<DatabaseConnection> conns;
	public SqlConnectionsView () {
		this.orientation = Gtk.Orientation.HORIZONTAL;
		this.spacing = 2;
		this.conns = new GLib.GenericArray<DatabaseConnection> ();
		this.realize.connect (() => {
			this.build_gui ();
			this.load_data ();
		});
	}

	void build_gui () {
		var expander = new Gtk.Expander ("Create Database connection");
		this.data = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
		expander.child = new SqlConnectionCreator (this.data, this.conns);
		this.append (expander);
		var sc = new Gtk.ScrolledWindow ();
		sc.child = data;
		this.append (sc);
	}

	void load_data () {
	}
}

public class SSHConfig : Object {
	public string host;
	public int port;
	public string? user;
	public string key;
	public string? phrase;
}

public class DatabaseConnection : Object {
	public string alias;
	public string dsn;
	public string driver;
	public SSHConfig? config;
}

public class SqlConnectionCreator : Gtk.Box {
	private Gtk.Box append_here;
	private Adw.EntryRow alias;
	private Gtk.Expander expander;
	private Gtk.Box buttons;
	private SqlConnectionSubCreator pqsql;
	private SqlConnectionSubCreator mysql;
	private SqlConnectionSubCreator sqlite;
	private SSHConnectionCreator ssh;
	private GLib.GenericArray<DatabaseConnection> conns;

	public SqlConnectionCreator (Gtk.Box append_here, GLib.GenericArray<DatabaseConnection> conns) {
		this.append_here = append_here;
		this.conns = conns;
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
		this.ssh = new SSHConnectionCreator ();
		this.expander.child = this.ssh;
		this.append (this.expander);
		this.buttons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
		var clear_all = new Gtk.Button.with_label ("Clear");
		clear_all.get_style_context ().add_class ("destructive-action");
		clear_all.clicked.connect (() => {
			this.clear ();
		});
		this.buttons.append (clear_all);
		var save = new Gtk.Button.with_label ("Save");
		save.get_style_context ().add_class ("suggested-action");
		save.clicked.connect (() => {
			this.save ((SqlConnectionSubCreator)tabview.selected_page.child);
			this.clear ();
		});
		this.buttons.append (save);
		this.buttons.halign = Gtk.Align.END;
		this.append (this.buttons);
	}

	void save (SqlConnectionSubCreator c) {
		var invalid_strings = new string[0];
		if (this.alias.text.strip () == "")
			invalid_strings += "Missing alias";
		foreach (var s in this.ssh.validate ())
			invalid_strings += s;
		foreach (var s in c.validate ())
			invalid_strings += s;
		if (invalid_strings.length > 0) {
			var dialog = new Adw.MessageDialog (null, "Error creating connection", "Couldn't create connection due to these errors");
			var extra = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
			foreach (var s in invalid_strings) {
				var row = new Gtk.Label (s);
				extra.append (row);
			}
			dialog.extra_child = extra;
			dialog.add_response ("close", "Close");
			dialog.set_close_response ("close");
			dialog.present ();
			return;
		}
	}

	void clear () {
		this.sqlite.clear ();
		this.mysql.clear ();
		this.pqsql.clear ();
		this.ssh.clear ();
	}
}

public class SSHConnectionCreator : Gtk.Box {
	private Adw.EntryRow host;
	private Gtk.SpinButton port;
	private Adw.EntryRow user;
	private Adw.EntryRow key;
	private Adw.PasswordEntryRow password;

	public SSHConnectionCreator () {
		this.spacing = 2;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.host = new Adw.EntryRow ();
		this.host.title = "Host";
		this.port = new Gtk.SpinButton.with_range (1, 65536, 1);
		this.port.value = 22;
		this.user = new Adw.EntryRow ();
		this.user.title = "User";
		this.key = new Adw.EntryRow ();
		this.key.title = "Private Key";
		this.password = new Adw.PasswordEntryRow ();
		this.password.title = "Passphrase";
		this.append (this.host);
		this.append (this.port);
		this.append (this.user);
		this.append (this.key);
		this.append (this.password);
	}

	public void clear () {
		this.host.text = "";
		this.port.value = 22;
		this.user.text = "";
		this.key.text = "";
		this.password.text = "";
	}

	public string[] validate () {
		var ht = this.host.text.strip ();
		var kt = this.key.text.strip ();
		if (ht == "" && this.port.value == 22 && this.user.text.strip () == "" && kt == "" && this.password.text.strip () == "")
			return new string[0];
		var ret = new string[0];
		if (ht == "")
			ret += "Missing host";
		if (kt == "")
			ret += "Missing private key path";
		return ret;
	}
}

public abstract class SqlConnectionSubCreator : Gtk.Box {
	public abstract void clear ();
	public abstract string[] validate ();
}

public class SQLiteConnectionCreator : SqlConnectionSubCreator {
	private Adw.EntryRow file;
	public SQLiteConnectionCreator () {
		this.spacing = 2;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.file = new Adw.EntryRow ();
		this.file.title = "Path to file";
		this.append (this.file);
	}

	public override void clear () {
		this.file.text = "";
	}
	public override string[] validate () {
		var ret = new string[0];
		if (this.file.text.strip () == "")
			ret += "Missing filepath";
		return ret;
	}
}

public class MySQLConnectionCreator : SqlConnectionSubCreator {
	private Adw.EntryRow user;
	private Adw.PasswordEntryRow password;
	private Gtk.ComboBoxText protocol;
	private Adw.EntryRow address;
	private Adw.EntryRow dbname;
	public MySQLConnectionCreator () {
		this.spacing = 2;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.user = new Adw.EntryRow ();
		this.user.title = "Username";
		this.append (this.user);
		this.password = new Adw.PasswordEntryRow ();
		this.password.title = "Password";
		this.append (this.password);
		this.protocol = new Gtk.ComboBoxText ();
		this.protocol.append_text ("tcp");
		this.protocol.append_text ("tcp4");
		this.protocol.append_text ("tcp6");
		this.protocol.append_text ("udp");
		this.protocol.append_text ("udp4");
		this.protocol.append_text ("udp6");
		this.protocol.append_text ("ip");
		this.protocol.append_text ("ip4");
		this.protocol.append_text ("ip6");
		this.protocol.append_text ("unix");
		this.protocol.append_text ("unixgram");
		this.protocol.append_text ("unixpacket");
		this.protocol.append_text ("");
		this.protocol.active = 0;
		this.append (this.protocol);
		this.address = new Adw.EntryRow ();
		this.address.title = "Hostname/IP-Address";
		this.append (this.address);
		this.dbname = new Adw.EntryRow ();
		this.dbname.title = "Database name";
		this.append (this.dbname);
	}

	public override void clear () {
		this.user.text = "";
		this.password.text = "";
		this.protocol.active = 0;
		this.address.text = "";
		this.dbname.text = "";
	}

	public override string[] validate () {
		var ret = new string[0];
		if (this.user.text.strip () == "" && this.password.text.strip () != "")
			ret += "Missing username";
		if (this.protocol.active_id == "" && this.address.text.strip () != "")
			ret += "Missing protocol";
		return ret;
	}
}
// https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING
public class PostgresConnectionCreator : SqlConnectionSubCreator {
	private Adw.EntryRow user;
	private Adw.PasswordEntryRow password;
	private Adw.EntryRow host;
	private Adw.EntryRow dbname;
	public PostgresConnectionCreator () {
		this.spacing = 2;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.user = new Adw.EntryRow ();
		this.user.title = "Username";
		this.append (this.user);
		this.password = new Adw.PasswordEntryRow ();
		this.password.title = "Password";
		this.append (this.password);
		this.host = new Adw.EntryRow ();
		this.host.title = "Hostname/IP-Address";
		this.append (this.host);
		this.dbname = new Adw.EntryRow ();
		this.dbname.title = "Database name";
		this.append (this.dbname);
	}

	public override void clear () {
		this.user.text = "";
		this.password.text = "";
		this.host.text = "";
		this.dbname.text = "";
	}
	public override string[] validate () {
		var ret = new string[0];
		if (this.user.text.strip () == "" && this.password.text.strip () != "")
			ret += "Missing username";
		if (this.dbname.text.strip () == "")
			ret += "Missing dbname";
		return ret;
	}
}
public class SqlConnectionEntry : Adw.ActionRow {
	public SqlConnectionEntry (string alias) {
		var btn = new Gtk.Button.from_icon_name ("small-x-symbolic");
		this.add_prefix (btn);
		this.title = alias;
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (SqlConnectionsWorkspaceAddin));
}