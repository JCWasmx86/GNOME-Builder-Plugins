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
	public void indent (GtkSource.View view, ref Gtk.TextIter iter) {
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
}
