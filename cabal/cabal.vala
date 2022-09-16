/* cabal.vala
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

public class CabalBuildSystemDiscovery : Ide.SimpleBuildSystemDiscovery {
	construct {
		this.glob = "*.cabal";
		this.priority = 900;
		this.hint = "cabal";
	}
}

public class CabalRunCommandProvider : Ide.Object, Ide.RunCommandProvider {
	public async GLib.ListModel list_commands_async (GLib.Cancellable? cancellable) throws GLib.Error {
		var context = this.get_context ();
		var store = new GLib.ListStore (typeof (Ide.RunCommand));
		if (!(Ide.BuildSystem.from_context (context) is CabalBuildSystem)) {
			info ("Not a cabal build system");
			return store;
		}
		var command = new Ide.RunCommand ();
		command.set_id ("cabal:run");
		command.set_priority (-500);
		command.set_display_name ("cabal run");
		command.can_default = true;
		var cabal = Environment.get_home_dir () + "/.ghcup/bin/cabal";
		command.set_cwd (Ide.BuildSystem.from_context (context).project_file.get_path ());
		info ("Setting cwd for `cabal run' to %s", command.cwd);
		command.set_argv (new string[] { cabal, "run" });
		store.append (command);
		return store;
	}
}

public class CabalBuildSystem : Ide.Object, Ide.BuildSystem {
	[NoAccessorMethod]
	public override GLib.File project_file { owned get; construct; }
	public string get_id () {
		return "cabal";
	}

	public string get_display_name () {
		return "Cabal";
	}

	public int get_priority () {
		return 900;
	}

	public string get_builddir (Ide.Pipeline pipeline) {
		return pipeline.get_srcdir ();
	}
}

public class CabalPipelineAddin : Ide.Object, Ide.PipelineAddin {
	public void unload (Ide.Pipeline pipeline) {
	}

	public void prepare (Ide.Pipeline pipeline) {
	}

	public void load (Ide.Pipeline pipeline) {
		var context = this.get_context ();
		var srcdir = pipeline.get_srcdir ();
		if (!(Ide.BuildSystem.from_context (context) is CabalBuildSystem)) {
			info ("Not a cabal build system");
			return;
		}
		var cabal = Environment.get_home_dir () + "/.ghcup/bin/cabal";
		var build_command = new Ide.RunCommand ();
		build_command.set_argv (new string[] { cabal, "build" });
		build_command.set_cwd (srcdir);
		var clean_command = new Ide.RunCommand ();
		clean_command.set_argv (new string[] { cabal, "clean" });
		clean_command.set_cwd (srcdir);
		var build_stage = new Ide.PipelineStageCommand (build_command, clean_command);
		build_stage.set_name ("Building project");
		build_stage.query.connect ((stage, targets, cancellable) => {
			build_stage.set_completed (false);
		});
		var id = pipeline.attach (Ide.PipelinePhase.BUILD, 0, build_stage);
		this.track (id);
	}
}

[ModuleInit]
public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.BuildSystemDiscovery), typeof (CabalBuildSystemDiscovery));
	obj.register_extension_type (typeof (Ide.BuildSystem), typeof (CabalBuildSystem));
	obj.register_extension_type (typeof (Ide.PipelineAddin), typeof (CabalPipelineAddin));
	obj.register_extension_type (typeof (Ide.RunCommandProvider), typeof (CabalRunCommandProvider));
}