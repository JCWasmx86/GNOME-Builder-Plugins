/* sqls.vala
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

class SqlsService : Ide.LspService {
	construct {
		this.set_program ("sqls");
		this.set_inherit_stderr (true);
	}
	public override void configure_launcher (Ide.Pipeline pipeline, Ide.SubprocessLauncher launcher) {
	}

	public override void configure_client (Ide.LspClient client) {
		client.add_language ("sql");
	}
}

class SqlsCodeActionProvider : Ide.LspCodeActionProvider, Ide.CodeActionProvider {
	public void load () {
		bind_client (this);
	}
}

class SqlsCompletionProvider : Ide.LspCompletionProvider, GtkSource.CompletionProvider {
	public override void load () {
		bind_client (this);
	}
}

class SqlsFormatter : Ide.LspFormatter, Ide.Formatter {
	public void load () {
		bind_client (this);
	}
}

public class SqlsHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
	public override void prepare () {
		this.priority = 800;
		bind_client (this);
	}
}

public class SqlsRenameProvider : Ide.LspRenameProvider, Ide.RenameProvider {
	public void load () {
		bind_client (this);
	}
}

public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.CodeActionProvider), typeof (SqlsCodeActionProvider));
	obj.register_extension_type (typeof (GtkSource.CompletionProvider), typeof (SqlsCompletionProvider));
	obj.register_extension_type (typeof (Ide.Formatter), typeof (SqlsFormatter));
	obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (SqlsHoverProvider));
	obj.register_extension_type (typeof (Ide.RenameProvider), typeof (SqlsRenameProvider));
}