/* meson.vala
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

public class MesonService : Ide.LspService {
	construct {
		this.set_inherit_stderr (true);
		// this.search_path = new string[] {"/usr/local/bin", "/usr/bin", "/var/run/host/usr/bin", "/var/run/host/usr/local/bin"};
		this.set_program ("meson_lsp");
	}

	public override void configure_launcher (Ide.Pipeline pipeline, Ide.SubprocessLauncher launcher) {
		launcher.set_environ (new string[] {"G_MESSAGES_DEBUG=all", "G_DEBUG=fatal-criticals", "DISPLAY=:0"});
		launcher.run_on_host = true;
	}
	public override void configure_client (Ide.LspClient client) {
		client.add_language ("meson");
	}
}

public sealed class MesonDiagnosticProvider : Ide.LspDiagnosticProvider, Ide.DiagnosticProvider {
	public void load () {
		bind_client (this);
	}
}

public class MesonSymbolResolver : Ide.LspSymbolResolver, Ide.SymbolResolver {
	public void load () {
		bind_client (this);
	}
}

public class MesonHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
	public override void prepare () {
		this.priority = 800;
		bind_client (this);
	}
}

public class MesonHighlighter : Ide.LspHighlighter {
	public new void load () {
		bind_client (this);
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (MesonDiagnosticProvider));
	obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (MesonSymbolResolver));
	obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (MesonHoverProvider));
	obj.register_extension_type (typeof (Ide.Highlighter), typeof (MesonHighlighter));
	info ("Loaded mesonlsp plugin");
}
