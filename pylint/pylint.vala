/* pylint.vala
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

public class PylintDiagnostic : GLib.Object {
	public string message_id { get; set; }
	public int line { get; set; }
	public int column { get; set; }


	public string message { get; set; }

	public Ide.Diagnostic to_ide (GLib.File file, string type) {
		var location = new Ide.Location (file, this.line - 1, this.column);
		var severity = Ide.DiagnosticSeverity.ERROR;
		if (type == "refactor" || type == "convention" || type == "informational")
			severity = Ide.DiagnosticSeverity.NOTE;
		else if (type == "warning")
			severity = Ide.DiagnosticSeverity.WARNING;
		else if (type == "fatal")
			severity = Ide.DiagnosticSeverity.FATAL;
		return new Ide.Diagnostic (severity, "[%s] %s".printf (this.message_id, this.message), location);
	}
}
public class PylintDiagnosticProvider : Ide.DiagnosticTool {
	construct {
		this.program_name = "pylint";
	}
	public override void populate_diagnostics (Ide.Diagnostics diagnostics, GLib.File file, string stdout_buf, string stderr_buf) {
		if (stdout_buf == null)
			return;
		var parser = new Json.Parser ();
		try {
			parser.load_from_data (stdout_buf);
		} catch (Error e) {
			critical ("%s", e.message);
			return;
		}
		var root = parser.get_root ();
		if (root == null || root.get_node_type () != Json.NodeType.ARRAY)
			return;
		var array = root.get_array ();
		info ("Found %u diagnostics", array.get_length ());
		for (var i = 0; i < array.get_length (); i++) {
			var diag = (PylintDiagnostic) Json.gobject_deserialize (typeof (PylintDiagnostic), array.get_element (i));
			diagnostics.add (diag.to_ide (file, array.get_element (i).get_object ().get_string_member ("type")));
		}
	}

	public PylintDiagnosticProvider () {
		this.program_name = "pylint";
	}

	public override void configure_launcher (Ide.SubprocessLauncher launcher, GLib.File file, GLib.Bytes contents, string language_id) {
		launcher.push_argv ("-f");
		launcher.push_argv ("json");
		launcher.push_argv (file.get_path ());
		launcher.setenv ("SHELL", "/bin/bash", false);
	}

	public override bool can_diagnose (GLib.File file, GLib.Bytes contents, string language_id) {
		return language_id == "python3";
	}
}
[ModuleInit]
public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (PylintDiagnosticProvider));
}