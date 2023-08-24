/* gtkcsslanguageserver.vala
 *
 * Copyright 2023 JCWasmx86 <JCWasmx86@t-online.de>
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

class GtkCSSLanguageServerService : Ide.LspService {
    construct {
        this.set_program ("gtkcsslanguageserver");
        this.set_inherit_stderr (true);
    }

    public override void prepare_run_context (Ide.Pipeline pipeline, Ide.RunContext run_context) {
    }

    public override void configure_client (Ide.LspClient client) {
        client.add_language ("css");
    }
}

class GtkCSSLanguageServerCompletionProvider : Ide.LspCompletionProvider, GtkSource.CompletionProvider {
    public override void load () {
        bind_client (this);
    }
}

class GtkCSSLanguageServerDiagnosticProvider : Ide.LspDiagnosticProvider, Ide.DiagnosticProvider {
    public void load () {
        bind_client (this);
    }
}

public class GtkCSSLanguageServerHoverProvider : Ide.LspHoverProvider, GtkSource.HoverProvider {
    public override void prepare () {
        this.priority = 80000;
        this.category = "GTK-CSS";
        bind_client (this);
    }
}


public class GtkCSSLanguageServerSymbolResolver : Ide.LspSymbolResolver, Ide.SymbolResolver {
    public void load () {
        bind_client (this);
    }
}

class GtkCSSLanguageServerFormatter : Ide.LspFormatter, Ide.Formatter {
    public void load () {
        bind_client (this);
    }
}

public void peas_register_types (TypeModule module) {
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (GtkSource.CompletionProvider), typeof (GtkCSSLanguageServerCompletionProvider));
    obj.register_extension_type (typeof (Ide.DiagnosticProvider), typeof (GtkCSSLanguageServerDiagnosticProvider));
    obj.register_extension_type (typeof (GtkSource.HoverProvider), typeof (GtkCSSLanguageServerHoverProvider));
    obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (GtkCSSLanguageServerSymbolResolver));
    obj.register_extension_type (typeof (Ide.Formatter), typeof (GtkCSSLanguageServerFormatter));
}
