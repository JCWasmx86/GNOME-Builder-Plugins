/* xmlfmt.vala
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
[CCode (cname = "xmlTreeIndentString")]
public static extern unowned string xmlTreeIndentString;

public class XmlFormatter : Ide.Object, Ide.Formatter {

	public async bool format_range_async (Ide.Buffer buffer, Ide.FormatterOptions options, Gtk.TextIter begin, Gtk.TextIter end, GLib.Cancellable? cancellable) {
		return false;
	}

	public void load () {
	}

	public async bool format_async (Ide.Buffer buffer, Ide.FormatterOptions options, GLib.Cancellable? cancellable) throws Error {
		var doc = Xml.Parser.parse_doc (buffer.text);
		if (doc == null) {
			var err = Xml.get_last_error ();
			if (err != null) {
				critical ("Error while attempting to parse XML: %s", err->message);
			} else {
				critical ("Unknown error while attempting to parse XML");
			}
			return false;
		}
		xmlTreeIndentString = options.insert_spaces ? (string.nfill (options.tab_width, ' ')) : "\t";
		string mem;
		int len;
		doc->dump_memory_enc_format (out mem, out len, "UTF-8", true);
		buffer.set_text (mem, len);
		return true;
	}
}
[ModuleInit]
public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.Formatter), typeof (XmlFormatter));
}