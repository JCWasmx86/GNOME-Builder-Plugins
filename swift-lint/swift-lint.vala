/* swift-lint.vala
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
public class SwiftLintDiagnostic : GLib.Object {
	public string rule_id { get; set; }
	public int line { get; set; }
	public int character { get; set; }
	public string reason { get; set; }
	public string severity { get; set; }

	public Ide.Diagnostic to_ide (GLib.File file, string type) {
		var location = new Ide.Location (file, this.line - 1, this.character);
		var severity = Ide.DiagnosticSeverity.ERROR;
		if (this.severity == "Warning")
			severity = Ide.DiagnosticSeverity.WARNING;
		else if (this.severity == "Error")
			severity = Ide.DiagnosticSeverity.FATAL;
		return new Ide.Diagnostic (severity, "[%s] %s".printf (this.rule_id, this.reason), location);
	}
}
public class SwiftLintDiagnosticProvider : Ide.DiagnosticTool {
	construct {
		this.program_name = "swiftlint";
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
			var diag = (SwiftLintDiagnostic) Json.gobject_deserialize (typeof (SwiftLintDiagnostic), array.get_element (i));
			diagnostics.add (diag.to_ide (file, array.get_element (i).get_object ().get_string_member ("type")));
		}
	}

	public SwiftLintDiagnosticProvider () {
		this.program_name = "swiftlint";
	}

	public override bool prepare_run_context (Ide.RunContext run_context, GLib.File file, GLib.Bytes contents, string language_id) throws Error {
		if (base.prepare_run_context (run_context, file, contents, language_id)) {
			run_context.append_argv ("--quiet");
			run_context.append_argv ("--reporter");
			run_context.append_argv ("json");
			// TODO: Should save before
			run_context.append_argv (file.get_path ());
			// TODO: Should not be hardcoded
			run_context.setenv ("LINUX_SOURCEKIT_LIB_PATH", "/usr/libexec/swift/5.7.2/lib/");
			return true;
		}
		return false;
	}

	public override bool can_diagnose (GLib.File file, GLib.Bytes contents, string language_id) {
		return language_id == "swift";
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (SwiftLintDiagnosticProvider));
}
