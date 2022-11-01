/* texlab.vala
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
[CCode (cname = "bind_client")]
extern void bind_client (Ide.Object self);

public class TexlabService : Ide.LspService {
	construct {
		this.set_inherit_stderr (true);
		this.search_path = new string[] { "/usr/local/bin", "/usr/bin", "/var/run/host/usr/bin", "/var/run/host/usr/local/bin" };
		this.set_program ("texlab");
	}

	public override void prepare_run_context (Ide.Pipeline pipeline, Ide.RunContext run_context) {
		run_context.append_argv ("-vvvv");
	}

	public override void configure_client (Ide.LspClient client) {
		client.add_language ("latex");
		client.add_language ("bibtex");
	}
}

class TexlabCompletionProvider : Ide.LspCompletionProvider, GtkSource.CompletionProvider {
	public override int get_priority (GtkSource.CompletionContext cc) {
		return -20000;
	}
	public override void load () {
		bind_client (this);
	}
}

class TexlabFormatter : Ide.LspFormatter, Ide.Formatter {
	public void load () {
		bind_client (this);
	}
}

public sealed class TexlabDiagnosticProvider : Ide.LspDiagnosticProvider, Ide.DiagnosticProvider {
	public void load () {
		bind_client (this);
	}
}

public class TexlabSymbolResolver : Ide.LspSymbolResolver, Ide.SymbolResolver {
	public void load () {
		bind_client (this);
	}
}

public class TexlabHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
	public override void prepare () {
		this.priority = 800;
		bind_client (this);
	}
}

public class TexlabHighlighter : Ide.LspHighlighter {
	public new void load () {
		bind_client (this);
	}
}

class TexlabRenameProvider : Ide.LspRenameProvider, Ide.RenameProvider {
	public void load () {
		bind_client (this);
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (GtkSource.CompletionProvider), typeof (TexlabCompletionProvider));
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (TexlabDiagnosticProvider));
	obj.register_extension_type (typeof (Ide.Formatter), typeof (TexlabFormatter));
	obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (TexlabSymbolResolver));
	obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (TexlabHoverProvider));
	obj.register_extension_type (typeof (Ide.Highlighter), typeof (TexlabHighlighter));
	obj.register_extension_type (typeof (Ide.RenameProvider), typeof (TexlabRenameProvider));
}
