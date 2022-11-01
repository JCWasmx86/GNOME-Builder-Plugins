/* sourcekit.vala
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
 * Original: Copyright 2022 Christian Hergert <chergert@redhat.com>
 * > https://gitlab.gnome.org/GNOME/gnome-builder/-/blob/main/src/plugins/Sourcekit
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
[CCode (cname = "bind_client")]
extern void bind_client (Ide.Object self);

class SourcekitService : Ide.LspService {
	construct {
		this.set_program ("sourcekit-lsp");
		this.set_inherit_stderr (true);
	}
	public override void prepare_run_context (Ide.Pipeline pipeline, Ide.RunContext run_context) {
		run_context.append_argv ("--log-level");
		run_context.append_argv ("debug");
	}

	public override void configure_client (Ide.LspClient client) {
		client.add_language ("swift");
	}
}

class SourcekitCodeActionProvider : Ide.LspCodeActionProvider, Ide.CodeActionProvider {
	public void load () {
		bind_client (this);
	}
}

class SourcekitCompletionProvider : Ide.LspCompletionProvider, GtkSource.CompletionProvider {
	public override void load () {
		bind_client (this);
	}
}

class SourcekitDiagnosticProvider : Ide.LspDiagnosticProvider, Ide.DiagnosticProvider {
	public void load () {
		bind_client (this);
	}
}

class SourcekitHighlighter : Ide.LspHighlighter, Ide.Highlighter {
	public void load () {
		bind_client (this);
	}
}

public class SourcekitHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
	public override void prepare () {
		this.priority = 80000;
		this.category = "Clang";
		bind_client (this);
	}
}

public class SourcekitSymbolResolver : Ide.LspSymbolResolver, Ide.SymbolResolver {
	public void load () {
		bind_client (this);
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.CodeActionProvider), typeof (SourcekitCodeActionProvider));
	obj.register_extension_type (typeof (GtkSource.CompletionProvider), typeof (SourcekitCompletionProvider));
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (SourcekitDiagnosticProvider));
	obj.register_extension_type (typeof (Ide.Highlighter), typeof (SourcekitHighlighter));
	obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (SourcekitHoverProvider));
	obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (SourcekitSymbolResolver));
}
