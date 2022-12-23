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
    private GLib.GenericArray<Gtk.Widget> widgets;

    public SqlConnectionsView () {
        this.orientation = Gtk.Orientation.VERTICAL;
        this.spacing = 2;
        this.conns = new GLib.GenericArray<DatabaseConnection> ();
        this.widgets = new GLib.GenericArray<Gtk.Widget> ();
        this.realize.connect (() => {
            this.build_gui ();
            this.load_data ();
        });
    }

    void build_gui () {
        var expander = new Gtk.Expander ("Create Database connection");
        this.data = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
        var scc = new SqlConnectionCreator (this.data, this.conns);
        expander.child = scc;
        scc.changed.connect (() => {
            Idle.add (() => {
                this.reload_connections ();
                return Source.REMOVE;
            });
        });
        this.append (expander);
        var sc = new Gtk.ScrolledWindow ();
        sc.child = data;
        data.hexpand = true;
        data.vexpand = true;
        this.append (sc);
        sc.vexpand = true;
        sc.hexpand = true;
    }

    void load_data () {
        var file = Environment.get_home_dir () + "/.config/sqls/config.yml";
        var f = File.new_for_path (file);
        try {
            var fis = new DataInputStream (f.read ());
            string? alias_ = null;
            string? driver = null;
            string? dsn = null;
            string? host = null;
            string? user = null;
            string? port = null;
            string? key = null;
            string? phrase = null;
            while (true) {
                var line = fis.read_line ();
                if (line == null)
                    break;
                line = line.strip ();
                if (line.has_prefix ("- alias")) {
                    if (alias_ != null) {
                        var sshconfig = host == null ? null : new SSHConfig (host, int.parse (port), user, key, phrase);
                        var dbcon = new DatabaseConnection (dsn, driver, alias_, sshconfig);
                        this.conns.add ((owned) dbcon);
                        alias_ = null;
                        driver = null;
                        dsn = null;
                        host = null;
                        user = null;
                        port = null;
                        key = null;
                        phrase = null;
                    }
                    alias_ = line.split (":", 2)[1].strip ();
                } else if (line == "connections:" || line == "sshConfig") {
                    continue;
                } else if (line.has_prefix ("driver:")) {
                    driver = line.split (":", 2)[1].strip ();
                } else if (line.has_prefix ("dataSourceName:")) {
                    dsn = line.split (":", 2)[1].strip ();
                } else if (line.has_prefix ("host:")) {
                    host = line.split (":", 2)[1].strip ();
                } else if (line.has_prefix ("port:")) {
                    port = line.split (":", 2)[1].strip ();
                } else if (line.has_prefix ("user:")) {
                    user = line.split (":", 2)[1].strip ();
                } else if (line.has_prefix ("privateKey:")) {
                    key = line.split (":", 2)[1].strip ();
                } else if (line.has_prefix ("passPhrase:")) {
                    phrase = line.split (":", 2)[1].strip ();
                }
            }
            if (alias_ != null) {
                var sshconfig = host == null ? null : new SSHConfig (host, int.parse (port), user, key, phrase);
                var dbcon = new DatabaseConnection (dsn, driver, alias_, sshconfig);
                this.conns.add ((owned) dbcon);
            }
            fis.close ();
            Idle.add (() => {
                this.reload_connections ();
                return Source.REMOVE;
            });
        } catch (Error e) {
            warning ("%s", e.message);
        }
    }

    void reload_connections () {
        foreach (var w in this.widgets)
            this.data.remove (w);
        var i = 0;
        foreach (var w in this.conns) {
            var sce = new SqlConnectionEntry (w.alias, i);
            sce.removed.connect (idx => {
                conns.remove_index (idx);
                Idle.add (() => {
                    this.reload_connections ();
                    return Source.REMOVE;
                });
            });
            this.widgets.add (sce);
            this.data.append (sce);
            i++;
        }
        this.make_backup ();
        this.write ();
    }

    void make_backup () {
        var file = Environment.get_home_dir () + "/.config/sqls/config.yml";
        var f = File.new_for_path (file);
        if (f.query_exists ()) {
            try {
                f.get_parent ().make_directory_with_parents ();
            } catch (Error e) {
                info ("%s", e.message);
            }
            var backup = File.new_for_path (Environment.get_home_dir () + "/.config/sqls/config.yml.gbbak");
            try {
                if (backup.query_exists ())
                    backup.delete ();
                f.copy (backup, GLib.FileCopyFlags.ALL_METADATA | GLib.FileCopyFlags.OVERWRITE, null, null);
            } catch (Error e) {
                critical ("%s", e.message);
            }
        }
    }

    void write () {
        var file = Environment.get_home_dir () + "/.config/sqls/config.yml";
        var f = File.new_for_path (file);
        try {
            f.get_parent ().make_directory_with_parents ();
        } catch (Error e) {
            info ("%s", e.message);
        }
        try {
            if (f.query_exists ())
                f.delete ();
            var os = f.create (GLib.FileCreateFlags.REPLACE_DESTINATION);
            os.write ("connections:\n".data);
            foreach (var c in this.conns) {
                os.write (("  - alias: " + c.alias + "\n").data);
                os.write (("    driver: " + c.driver + "\n").data);
                os.write (("    dataSourceName: " + c.dsn + "\n").data);
                if (c.config != null) {
                    var con = c.config;
                    os.write ("    sshConfig:\n".data);
                    os.write (("     host: " + con.host + "\n").data);
                    os.write (("     port: " + "%d\n".printf (con.port)).data);
                    if (con.user != null)
                        os.write (("     user: " + con.user + "\n").data);
                    os.write (("     privateKey: " + con.key + "\n").data);
                    if (con.phrase != null)
                        os.write (("     passPhrase: " + con.phrase + "\n").data);
                }
            }
            os.close ();
        } catch (Error e) {
            critical ("%s", e.message);
        }
    }
}

public class SSHConfig : Object {
    public string host;
    public int port;
    public string? user;
    public string key;
    public string? phrase;

    public SSHConfig (string host, int port, string user, string key, string phrase) {
        this.host = host;
        this.port = port;
        this.user = user == "" ? null : user;
        this.key = key;
        this.phrase = phrase == "" ? null : phrase;
    }
}

public class DatabaseConnection : Object {
    public string alias;
    public string dsn;
    public string driver;
    public SSHConfig? config;

    public DatabaseConnection (string dsn, string driver, string alias, SSHConfig? config) {
        this.alias = alias;
        this.dsn = dsn;
        this.driver = driver;
        this.config = config;
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
            this.save ((SqlConnectionSubCreator) tabview.selected_page.child);
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
        foreach (var con in this.conns) {
            if (this.alias.text.down () == con.alias.down ())
                invalid_strings += "Duplicate alias: " + con.alias;
        }
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
        var dsn = c.gen_dsn ();
        var driver = c.driver;
        var alias = this.alias.text.strip ();
        var config = this.ssh.gen_config ();
        var new_con = new DatabaseConnection (dsn, driver, alias, config);
        this.conns.insert (0, (owned) new_con);
        this.changed ();
    }

    void clear () {
        this.alias.text = "";
        this.sqlite.clear ();
        this.mysql.clear ();
        this.pqsql.clear ();
        this.ssh.clear ();
    }

    public signal void changed ();
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

    public SSHConfig ? gen_config () {
        var ht = this.host.text.strip ();
        var kt = this.key.text.strip ();
        if (ht == "" && this.port.value == 22 && this.user.text.strip () == "" && kt == "" && this.password.text.strip () == "")
            return null;
        return new SSHConfig (this.host.text.strip (), (int) this.port.value, this.user.text.strip (), this.key.text.strip (), this.password.text.strip ());
    }
}

public abstract class SqlConnectionSubCreator : Gtk.Box {
    public string driver;
    public abstract void clear ();

    public abstract string[] validate ();
    public abstract string gen_dsn ();
}

public class SQLiteConnectionCreator : SqlConnectionSubCreator {
    private Adw.EntryRow file;
    public SQLiteConnectionCreator () {
        this.spacing = 2;
        this.driver = "sqlite3";
        this.orientation = Gtk.Orientation.VERTICAL;
        this.file = new Adw.EntryRow ();
        this.file.title = "Path to file";
        this.append (this.file);
    }

    public override string gen_dsn () {
        return "file:" + this.file.text;
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
        this.driver = "mysql";
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
        if (this.protocol.get_active_text () == "" && this.address.text.strip () != "")
            ret += "Missing protocol";
        return ret;
    }

    public override string gen_dsn () {
        var sb = new StringBuilder ();
        if (this.user.text.strip () != "") {
            sb.append (this.user.text.strip ());
            if (this.password.text.strip () != "") {
                sb.append_c (':').append (this.password.text.strip ());
            }
            sb.append_c ('@');
        }
        if (this.protocol.get_active_text () != "") {
            sb.append (this.protocol.get_active_text ());
            if (this.address.text.strip () != "") {
                sb.append_c ('(').append (this.address.text.strip ()).append_c (')');
            }
        }
        sb.append ("/");
        if (this.dbname.text.strip () != "")
            sb.append (this.dbname.text.strip ());
        return sb.str;
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
        this.driver = "postgresql";
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

    public override string gen_dsn () {
        var sb = new StringBuilder ();
        sb.append ("postgres://");
        if (this.user.text.strip () != "") {
            sb.append (this.user.text.strip ());
            if (this.password.text.strip () != "") {
                sb.append_c (':').append (this.password.text.strip ());
            }
            sb.append_c ('@');
        }
        if (this.host.text.strip () != "") {
            sb.append (this.host.text.strip ());
        }
        if (this.dbname.text.strip () != "")
            sb.append_c ('/').append (this.dbname.text.strip ());
        return sb.str;
    }
}
public class SqlConnectionEntry : Adw.ActionRow {
    public SqlConnectionEntry (string alias, uint index) {
        var btn = new Gtk.Button.from_icon_name ("small-x-symbolic");
        btn.tooltip_text = "Remove";
        btn.clicked.connect (() => {
            this.removed (index);
        });
        this.add_prefix (btn);
        this.title = alias;
    }

    public signal void removed (uint index);
}

public void peas_register_types (TypeModule module) {
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.WorkspaceAddin), typeof (SqlConnectionsWorkspaceAddin));
}
