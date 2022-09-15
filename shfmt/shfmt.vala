/* shfmt.vala
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

public class ShfmtFormatter : Ide.Object, Ide.Formatter {

	public async bool format_range_async (Ide.Buffer buffer, Ide.FormatterOptions options, Gtk.TextIter begin, Gtk.TextIter end, GLib.Cancellable? cancellable) {
		return false;
	}

	public void load () {

	}

	public async bool format_async (Ide.Buffer buffer, Ide.FormatterOptions options, GLib.Cancellable? cancellable) throws Error {
		var l = new Ide.SubprocessLauncher (GLib.SubprocessFlags.STDIN_PIPE | GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE);
		l.set_cwd ("/");
		l.set_run_on_host (true);
		l.push_args (new string[] {"shfmt", "-i", "%u".printf (options.insert_spaces ? options.tab_width : 0), "-"});
		var proc = l.spawn ();
		string stdout_buf;
		string stderr_buf;
		proc.communicate_utf8 (buffer.text, null, out stdout_buf, out stderr_buf);
		proc.wait ();
		if (!proc.get_successful ()) {
			return false;
		}
		buffer.set_text (stdout_buf, stdout_buf.length);
		return true;
	}
}
[ModuleInit]
public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.Formatter), typeof (ShfmtFormatter));
}
