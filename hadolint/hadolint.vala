/* hadolint.vala
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

public class HadolintDiagnostic : GLib.Object {
    public string code { get; set; }
    public int line { get; set; }
    public int column { get; set; }
    public string message { get; set; }
    public string level { get; set; }

    public Ide.Diagnostic to_ide (GLib.File file) {
        var location = new Ide.Location (file, this.line - 1, this.column);
        var severity = Ide.DiagnosticSeverity.IGNORED;
        if (level == "info")
            severity = Ide.DiagnosticSeverity.NOTE;
        else if (level == "warning")
            severity = Ide.DiagnosticSeverity.WARNING;
        else if (level == "error")
            severity = Ide.DiagnosticSeverity.ERROR;
        return new Ide.Diagnostic (severity, "[%s] %s".printf (this.code, this.message), location);
    }
}

public class HadolintDiagnosticProvider : Ide.DiagnosticTool {
    construct {
        this.program_name = "hadolint";
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
            var diag = (HadolintDiagnostic) Json.gobject_deserialize (typeof (HadolintDiagnostic), array.get_element (i));
            diagnostics.add (diag.to_ide (file));
        }
    }

    public HadolintDiagnosticProvider () {
        this.program_name = "hadolint";
    }

    public override bool prepare_run_context (Ide.RunContext run_context, GLib.File file, GLib.Bytes contents, string language_id) throws Error {
        if (base.prepare_run_context (run_context, file, contents, language_id)) {
            run_context.append_argv ("--format=json");
            run_context.append_argv ("-");
            run_context.set_cwd ("/");
            return true;
        }
        return false;
    }

    public override bool can_diagnose (GLib.File file, GLib.Bytes contents, string language_id) {
        return language_id == "docker";
    }
}


public void peas_register_types (TypeModule module) {
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (HadolintDiagnosticProvider));
}
