/* hls.vala
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

class HlsService : Ide.LspService {
	construct {
		this.set_program (Environment.get_home_dir () + "/.ghcup/bin/" + "haskell-language-server-wrapper1");
		this.set_inherit_stderr (true);
	}
	public override void configure_launcher (Ide.Pipeline pipeline, Ide.SubprocessLauncher launcher) {
		launcher.push_argv ("--lsp");
		launcher.push_argv ("--debug");
		launcher.push_argv ("--logfile");
		launcher.push_argv (Environment.get_user_cache_dir () + "/hls.log");
		launcher.prepend_path (Environment.get_home_dir () + "/.ghcup/bin");
		launcher.prepend_path ("/usr/bin");
		launcher.prepend_path ("/usr/local/bin");
		launcher.set_run_on_host (false);
		launcher.setenv ("PATH", Environment.get_home_dir () + "/.ghcup/bin:/app/bin/:/usr/bin/:" + Environment.get_variable ("PATH"), true);
	}

	public override void configure_client (Ide.LspClient client) {
		client.add_language ("haskell");
	}
}

class HlsCodeActionProvider : Ide.LspCodeActionProvider, Ide.CodeActionProvider {
	public void load () {
		bind_client (this);
	}
}

class HlsCompletionProvider : Ide.LspCompletionProvider, GtkSource.CompletionProvider {
	public override void load () {
		bind_client (this);
	}
}

class HlsDiagnosticProvider : Ide.LspDiagnosticProvider, Ide.DiagnosticProvider {
	public void load () {
		bind_client (this);
	}
}

class HlsFormatter : Ide.LspFormatter, Ide.Formatter {
	public void load () {
		bind_client (this);
	}
}

class HlsHighlighter : Ide.LspHighlighter, Ide.Highlighter {
	public void load () {
		bind_client (this);
	}
}

public class HlsHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
	public override void prepare () {
		this.priority = 800;
		bind_client (this);
	}
}

public class HlsRenameProvider : Ide.LspRenameProvider, Ide.RenameProvider {
	public void load () {
		bind_client (this);
	}
}

public class HlsSymbolResolver : Ide.LspSymbolResolver, Ide.SymbolResolver {
	public void load () {
		bind_client (this);
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.CodeActionProvider), typeof (HlsCodeActionProvider));
	obj.register_extension_type (typeof (GtkSource.CompletionProvider), typeof (HlsCompletionProvider));
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (HlsDiagnosticProvider));
	obj.register_extension_type (typeof (Ide.Formatter), typeof (HlsFormatter));
	obj.register_extension_type (typeof (Ide.Highlighter), typeof (HlsHighlighter));
	obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (HlsHoverProvider));
	obj.register_extension_type (typeof (Ide.RenameProvider), typeof (HlsRenameProvider));
	obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (HlsSymbolResolver));
}
