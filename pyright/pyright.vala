/* pyright.vala
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

class PyrightService : Ide.LspService {
    construct {
        this.set_program ("pyright-python-langserver");
        this.set_inherit_stderr (true);
    }

    public override void prepare_run_context (Ide.Pipeline pipeline, Ide.RunContext run_context) {
        run_context.append_argv ("--stdio");
    }

    public override void configure_client (Ide.LspClient client) {
        client.add_language ("python");
        client.add_language ("python3");
    }
}

class PyrightCodeActionProvider : Ide.LspCodeActionProvider, Ide.CodeActionProvider {
    public void load () {
        bind_client (this);
    }
}

class PyrightCompletionProvider : Ide.LspCompletionProvider, GtkSource.CompletionProvider {
    public override void load () {
        bind_client (this);
    }
}

class PyrightDiagnosticProvider : Ide.LspDiagnosticProvider, Ide.DiagnosticProvider {
    public void load () {
        bind_client (this);
    }
}

class PyrightFormatter : Ide.LspFormatter, Ide.Formatter {
    public void load () {
        bind_client (this);
    }
}

class PyrightHighlighter : Ide.LspHighlighter, Ide.Highlighter {
    public void load () {
        bind_client (this);
    }
}

public class PyrightHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
    public override void prepare () {
        this.priority = 80000;
        this.category = "Clang";
        bind_client (this);
    }
}

public class PyrightRenameProvider : Ide.LspRenameProvider, Ide.RenameProvider {
    public void load () {
        bind_client (this);
    }
}

public class PyrightSymbolResolver : Ide.LspSymbolResolver, Ide.SymbolResolver {
    public void load () {
        bind_client (this);
    }
}

public void peas_register_types (TypeModule module) {
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.CodeActionProvider), typeof (PyrightCodeActionProvider));
    obj.register_extension_type (typeof (GtkSource.CompletionProvider), typeof (PyrightCompletionProvider));
    obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (PyrightDiagnosticProvider));
    obj.register_extension_type (typeof (Ide.Formatter), typeof (PyrightFormatter));
    obj.register_extension_type (typeof (Ide.Highlighter), typeof (PyrightHighlighter));
    obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (PyrightHoverProvider));
    obj.register_extension_type (typeof (Ide.RenameProvider), typeof (PyrightRenameProvider));
    obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (PyrightSymbolResolver));
}
