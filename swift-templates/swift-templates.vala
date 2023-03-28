/* swift-templates.vala
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
public class SwiftTemplateProvider : Ide.Object, Ide.TemplateProvider {
    public GLib.List<Ide.ProjectTemplate> get_project_templates () {
        var ret = new GLib.List<Ide.ProjectTemplate> ();
        ret.append (new SwiftEmptyTemplate ());
        ret.append (new SwiftLibraryTemplate ());
        ret.append (new SwiftExecutableTemplate ());
        return ret;
    }
}

public class SwiftExecutableTemplate : Ide.ProjectTemplate {
    construct {
        this.set ("id", "swift.executable", "languages", new string[1] { "Swift" }, "name", "Executable", null);
    }

    public override async bool expand_async (Ide.TemplateInput input, Template.Scope scope, GLib.Cancellable? cancellable) throws GLib.Error {
        var directory = input.directory.get_child (input.name);
        if (!directory.query_exists (cancellable)) {
            directory.make_directory_with_parents (cancellable);
        }
        var ctx = create_context (directory.get_path (), "executable");
        var launcher = ctx.end ();
        launcher.spawn (cancellable);
        this.add_resource (input.get_license_path (), directory.get_child ("COPYING"), scope, 0);
        this.expand_all_async (cancellable);
        return true;
    }
}

public class SwiftEmptyTemplate : Ide.ProjectTemplate {
    construct {
        this.set ("id", "swift.empty", "languages", new string[1] { "Swift" }, "name", "Empty", null);
    }

    public override async bool expand_async (Ide.TemplateInput input, Template.Scope scope, GLib.Cancellable? cancellable) throws GLib.Error {
        var directory = input.directory.get_child (input.name);
        if (!directory.query_exists (cancellable)) {
            directory.make_directory_with_parents (cancellable);
        }
        var ctx = create_context (directory.get_path (), "empty");
        var launcher = ctx.end ();
        launcher.spawn (cancellable);
        this.add_resource (input.get_license_path (), directory.get_child ("COPYING"), scope, 0);
        this.expand_all_async (cancellable);
        return true;
    }
}

public class SwiftLibraryTemplate : Ide.ProjectTemplate {
    construct {
        this.set ("id", "swift.library", "languages", new string[1] { "Swift" }, "name", "Library", null);
    }

    public override async bool expand_async (Ide.TemplateInput input, Template.Scope scope, GLib.Cancellable? cancellable) throws GLib.Error {
        var directory = input.directory.get_child (input.name);
        if (!directory.query_exists (cancellable)) {
            directory.make_directory_with_parents (cancellable);
        }
        var ctx = create_context (directory.get_path (), "library");
        var launcher = ctx.end ();
        launcher.spawn (cancellable);
        this.add_resource (input.get_license_path (), directory.get_child ("COPYING"), scope, 0);
        this.expand_all_async (cancellable);
        return true;
    }
}

internal Ide.RunContext create_context (string path, string id) {
    var ret = new Ide.RunContext ();
    ret.push_host ();
    ret.push_shell (Ide.RunContextShell.DEFAULT);
    ret.append_args (new string[] { "swift", "package", "init", "--type", id });
    warning (path);
    ret.set_cwd (path);
    ret.add_minimal_environment ();
    return ret;
}

public void peas_register_types (TypeModule module) {
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type (typeof (Ide.TemplateProvider), typeof (SwiftTemplateProvider));
}
