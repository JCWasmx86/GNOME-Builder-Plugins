/* shellcheck.vala
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

public class ShellcheckDiagnosticProvider : Ide.DiagnosticTool {
	construct {
		this.program_name = "shellcheck";
	}
	public override void populate_diagnostics (Ide.Diagnostics diagnostics, GLib.File file, string stdout_buf, string stderr_buf) {
		warning ("Populating shellcheck diagnostics");
		if (stdout_buf == null)
			return;
		var lines = stdout_buf.split ("\n");
		foreach (var line in lines) {
			if (line == null || line.strip () == "")
				continue;
			var parts = line.split (" ", 3);
			if (parts.length != 3 || parts[0] == null || parts[0].strip () == "")
				continue;
			var raw_loc = parts[0].split (":");
			var start = new Ide.Location (file, int.parse (raw_loc[1]) - 1, int.parse (raw_loc[2]));
			var severity = Ide.DiagnosticSeverity.IGNORED;
			switch (parts[1].replace (":", "")) {
				case "warning":
					severity = Ide.DiagnosticSeverity.WARNING;
					break;
				case "error":
					severity = Ide.DiagnosticSeverity.ERROR;
					break;
				case "note":
					severity = Ide.DiagnosticSeverity.NOTE;
					break;
			}
			diagnostics.add (new Ide.Diagnostic (severity, parts[2], start));
		}
	}
	public ShellcheckDiagnosticProvider () {
		this.program_name = "shellcheck";
	}
	public override void configure_launcher (Ide.SubprocessLauncher launcher, GLib.File file, GLib.Bytes contents, string language_id) {
		launcher.push_argv ("--format=gcc");
		launcher.push_argv ("-");
		launcher.setenv ("SHELL", "/bin/bash", false);
	}
	public override bool can_diagnose (GLib.File file, GLib.Bytes contents, string language_id) {
		return language_id == "sh";
	}
}
[ModuleInit]
public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (ShellcheckDiagnosticProvider));
	info ("Loaded shellcheck plugin");
}
