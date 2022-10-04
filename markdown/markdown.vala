/* markdown.vala
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

public class MarkdownIndenter : Ide.Object, GtkSource.Indenter {
	private int? extract_number (string str) {
		for (var i = 0; i < str.length; i++) {
			warning ("%d '%c'", i, str[i]);
			if (str[i] >= '0' && str[i] <= '9') {
				continue;
			} else if (str[i] == '.' && i != 0) {
				return int.parse (str.substring (0, i));
			}
			break;
		}
		return null;
	}
	public void indent (GtkSource.View view, ref Gtk.TextIter iter) {
		/*
		 * 1. Add "- " automatically for unordered lists
		 * 2. Add "n. " automatically for ordered lists
		 * 3.
		 */
		var buf = view.buffer;
		var prev_line_no = iter.get_line ();
		Gtk.TextIter prev_iter;
		buf.get_iter_at_line (out prev_iter, prev_line_no - 1);
		var prev_line = prev_iter.get_text (iter);
		var prev_line_stripped = prev_line.chug ();
		var indent = prev_line.substring (0, prev_line.length - prev_line_stripped.length);
		if (prev_line_stripped.has_prefix ("- ")) {
			buf.insert (ref iter, "%s- ".printf (indent), -1);
			return;
		}
		var n = extract_number (prev_line_stripped);
		if (n != null) {
			buf.insert (ref iter, "%s%d. ".printf (indent, n + 1), -1);
		}
	}

	public bool is_trigger (GtkSource.View view, Gtk.TextIter location, Gdk.ModifierType state, uint keyval) {
		if ((state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SUPER_MASK)) != 0)
			return false;
		return keyval == Gdk.Key.Return || keyval == Gdk.Key.KP_Enter;
	}
}

public class MarkdownSymbolResolver : Ide.Object, Ide.SymbolResolver {
	public async Ide.Symbol? find_nearest_scope_async (Ide.Location location, GLib.Cancellable? cancellable) throws GLib.Error {
		return null;
	}

	public async GLib.GenericArray<Ide.Range> find_references_async (Ide.Location location, string? language_id, GLib.Cancellable? cancellable) throws GLib.Error {
		return new GLib.GenericArray<Ide.Range> ();
	}

	public async Ide.SymbolTree? get_symbol_tree_async (GLib.File file, GLib.Bytes? contents, GLib.Cancellable? cancellable) throws GLib.Error {
		return null;
	}

	public void load () {}

	public async Ide.Symbol? lookup_symbol_async (Ide.Location location, GLib.Cancellable? cancellable) throws GLib.Error {
		return null;
	}

	public void unload () {}
}

[ModuleInit]
public void peas_register_types (TypeModule module) {
	var obj = (Peas.ObjectModule) module;
	obj.register_extension_type (typeof (Ide.SymbolResolver), typeof (MarkdownSymbolResolver));
	obj.register_extension_type (typeof (GtkSource.Indenter), typeof (MarkdownIndenter));
}
