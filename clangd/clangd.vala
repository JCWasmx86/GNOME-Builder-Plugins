/* clangd.vala
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
 * > https://gitlab.gnome.org/GNOME/gnome-builder/-/blob/main/src/plugins/clangd
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
[CCode (cname = "bind_client")]
extern void bind_client (Ide.Object self);

class ClangdService : Ide.LspService {
	construct {
		this.set_program ("clangd");
		this.set_inherit_stderr (true);
	}
	public override void configure_launcher (Ide.Pipeline pipeline, Ide.SubprocessLauncher launcher) {
		critical ("compile-commands.json: %s", pipeline.get_builddir ());
		launcher.push_argv ("--completion-style=detailed");
		launcher.push_argv ("-j=4");
		launcher.push_argv ("--malloc-trim");
		launcher.push_argv ("--log=verbose");
		launcher.push_argv ("--compile-commands-dir=" + pipeline.get_builddir ());
		launcher.push_argv ("--pch-storage=memory");
	}
	public override void configure_client (Ide.LspClient client) {
		client.add_language ("c");
		client.add_language ("cpp");
		client.add_language ("objective-c");
		client.add_language ("objective-cpp");
	}
}

class ClangdCodeActionProvider : Ide.LspCodeActionProvider, Ide.CodeActionProvider {
	public void load () {
		bind_client (this);
	}
}

class ClangdCompletionProvider : Ide.LspCompletionProvider, GtkSource.CompletionProvider {
	public override void load () {
		bind_client (this);
	}
}

class ClangdDiagnosticProvider : Ide.LspDiagnosticProvider, Ide.DiagnosticProvider {
	public void load () {
		bind_client (this);
	}
}

class ClangdFormatter : Ide.LspFormatter, Ide.Formatter {
	public void load () {
		bind_client (this);
	}
}

class ClangdHighlighter : Ide.LspHighlighter, Ide.Highlighter {
	public void load () {
		bind_client (this);
	}
}

public class ClangdHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
	public override void prepare () {
		this.priority = 80000;
		this.category = "Clang";
		bind_client (this);
	}
}

public class ClangdRenameProvider : Ide.LspRenameProvider, Ide.RenameProvider {
	public void load () {
		bind_client (this);
	}
}

public class ClangdSymbolResolver : Ide.LspSymbolResolver, Ide.SymbolResolver {
	public void load () {
		bind_client (this);
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.CodeActionProvider), typeof (ClangdCodeActionProvider));
	obj.register_extension_type (typeof (GtkSource.CompletionProvider), typeof (ClangdCompletionProvider));
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (ClangdDiagnosticProvider));
	obj.register_extension_type (typeof (Ide.Formatter), typeof (ClangdFormatter));
	obj.register_extension_type (typeof (Ide.Highlighter), typeof (ClangdHighlighter));
	obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (ClangdHoverProvider));
	obj.register_extension_type (typeof (Ide.RenameProvider), typeof (ClangdRenameProvider));
	obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (ClangdSymbolResolver));
}
