/* stack.vala
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

public class StackBuildSystemDiscovery : Ide.SimpleBuildSystemDiscovery {
	public StackBuildSystemDiscovery () {
		this.glob = "stack.yaml";
	}
}

public class StackBuildSystem : Ide.Object, Ide.BuildSystem {
	[NoAccessorMethod]
	public override GLib.File project_file { owned get; construct; }
	public string get_id () {
		return "Stack";
	}

	public string get_display_name () {
		return "Stack";
	}

	public int get_priority () {
		return 2000;
	}
}

public class StackPipelineAddin : Ide.Object, Ide.PipelineAddin {
	public void unload (Ide.Pipeline pipeline) {
	}

	public void prepare (Ide.Pipeline pipeline) {
	}

	public void load (Ide.Pipeline pipeline) {
		var context = this.get_context ();
		var srcdir = pipeline.get_srcdir ();
		if (! (Ide.BuildSystem.from_context (context) is StackBuildSystem))
			return;
		try {
			var build_launcher = pipeline.create_launcher ();
			build_launcher.set_cwd (srcdir);
			build_launcher.push_args (new string[] { "stack", "build" });
			var clean_launcher = pipeline.create_launcher ();
			clean_launcher.set_cwd (srcdir);
			clean_launcher.push_args (new string[] { "stack", "clean" });
			var build_stage = new Ide.PipelineStageLauncher (context, build_launcher);
			build_stage.set_name ("Building project");
			build_stage.set_clean_launcher (clean_launcher);
			build_stage.query.connect ((stage, targets, cancellable) => {
				build_stage.set_completed (false);
			});
			var id = pipeline.attach (Ide.PipelinePhase.BUILD, 0, build_stage);
			this.track (id);
			var install_launcher = pipeline.create_launcher ();
			install_launcher.set_cwd (srcdir);
			install_launcher.push_args (new string[] { "stack", "install" });
			var install_stage = new Ide.PipelineStageLauncher (context, install_launcher);
			install_stage.set_name ("Installing project");
			id = pipeline.attach (Ide.PipelinePhase.INSTALL, 0, install_stage);
			this.track (id);
		} catch (Error e) {
			critical ("%s", e.message);
		}
	}
}

[ModuleInit]
public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.BuildSystemDiscovery), typeof (StackBuildSystemDiscovery));
	obj.register_extension_type (typeof (Ide.BuildSystem), typeof (StackBuildSystem));
	obj.register_extension_type (typeof (Ide.PipelineAddin), typeof (StackPipelineAddin));
	info ("Loaded stack plugin");
}
