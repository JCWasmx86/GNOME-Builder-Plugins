/* vte-2.91-gtk4.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Vte", gir_namespace = "Vte", gir_version = "3.91", lower_case_cprefix = "vte_")]
namespace Vte {
	[CCode (cheader_filename = "vte/vte.h", type_id = "vte_pty_get_type ()")]
	public class Pty : GLib.Object, GLib.Initable {
		[CCode (has_construct_function = false)]
		protected Pty ();
		public void child_setup ();
		[Version (deprecated = true, deprecated_since = "0.42")]
		public void close ();
		[CCode (has_construct_function = false)]
		public Pty.foreign_sync (int fd, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public int get_fd ();
		public bool get_size (out int rows, out int columns) throws GLib.Error;
		public bool set_size (int rows, int columns) throws GLib.Error;
		public bool set_utf8 (bool utf8) throws GLib.Error;
		[Version (since = "0.48")]
		public async bool spawn_async (string? working_directory, [CCode (array_length = false, array_null_terminated = true)] string[] argv, [CCode (array_length = false, array_null_terminated = true)] string[]? envv, GLib.SpawnFlags spawn_flags, [CCode (delegate_target_pos = 5.33333, destroy_notify_pos = 5.66667)] owned GLib.SpawnChildSetupFunc? child_setup, int timeout, GLib.Cancellable? cancellable, out GLib.Pid child_pid) throws GLib.Error;
		[Version (since = "0.62")]
		public async void spawn_with_fds_async (string? working_directory, [CCode (array_length = false, array_null_terminated = true)] string[] argv, [CCode (array_length = false, array_null_terminated = true)] string[]? envv, [CCode (array_length_cname = "n_fds", array_length_pos = 4.5)] int[]? fds, [CCode (array_length_cname = "n_map_fds", array_length_pos = 5.5)] int[]? map_fds, GLib.SpawnFlags spawn_flags, [CCode (delegate_target_pos = 7.33333, destroy_notify_pos = 7.66667)] owned GLib.SpawnChildSetupFunc? child_setup, int timeout, GLib.Cancellable? cancellable);
		[CCode (has_construct_function = false)]
		public Pty.sync (Vte.PtyFlags flags, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public int fd { get; construct; }
		[NoAccessorMethod]
		public Vte.PtyFlags flags { get; construct; }
	}
	[CCode (cheader_filename = "vte/vte.h", ref_function = "vte_regex_ref", type_id = "vte_regex_get_type ()", unref_function = "vte_regex_unref")]
	[Compact]
	public class Regex {
		[CCode (has_construct_function = false)]
		public Regex.for_match (string pattern, ssize_t pattern_length, uint32 flags) throws GLib.Error;
		[CCode (has_construct_function = false)]
		public Regex.for_search (string pattern, ssize_t pattern_length, uint32 flags) throws GLib.Error;
		public bool jit (uint32 flags) throws GLib.Error;
		public Vte.Regex @ref ();
		[Version (since = "0.56")]
		public string substitute (string subject, string replacement, uint32 flags) throws GLib.Error;
		[DestroysInstance]
		public Vte.Regex unref ();
	}
	[CCode (cheader_filename = "vte/vte.h", type_id = "vte_terminal_get_type ()")]
	public class Terminal : Gtk.Widget, Gtk.Accessible, Gtk.Buildable, Gtk.ConstraintTarget, Gtk.Scrollable {
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		public Terminal ();
		[Version (since = "0.70")]
		public string? check_hyperlink_at (double x, double y);
		[Version (since = "0.70")]
		public string? check_match_at (double x, double y, out int tag);
		[CCode (array_length_pos = 4.1, array_length_type = "gsize")]
		[Version (since = "0.70")]
		public string[]? check_regex_array_at (double x, double y, [CCode (array_length_cname = "n_regexes", array_length_pos = 3.5, array_length_type = "gsize")] Vte.Regex[] regexes, uint32 match_flags);
		[Version (since = "0.50")]
		public void copy_clipboard_format (Vte.Format format);
		public void copy_primary ();
		public void feed ([CCode (array_length_cname = "length", array_length_pos = 1.1, array_length_type = "gssize")] uint8[]? data);
		public void feed_child ([CCode (array_length_cname = "length", array_length_pos = 1.1, array_length_type = "gssize")] uint8[]? text);
		[Version (deprecated = true, deprecated_since = "0.60")]
		public void feed_child_binary ([CCode (array_length_cname = "length", array_length_pos = 1.1, array_length_type = "gsize")] uint8[]? data);
		[Version (deprecated = true, deprecated_since = "0.60")]
		public bool get_allow_bold ();
		[Version (since = "0.50")]
		public bool get_allow_hyperlink ();
		public bool get_audible_bell ();
		[Version (since = "0.52")]
		public bool get_bold_is_bright ();
		[Version (since = "0.52")]
		public double get_cell_height_scale ();
		[Version (since = "0.52")]
		public double get_cell_width_scale ();
		public long get_char_height ();
		public long get_char_width ();
		public int get_cjk_ambiguous_width ();
		[Version (since = "0.54")]
		public Gdk.RGBA get_color_background_for_draw ();
		public long get_column_count ();
		public unowned string? get_current_directory_uri ();
		public unowned string? get_current_file_uri ();
		public Vte.CursorBlinkMode get_cursor_blink_mode ();
		public void get_cursor_position (out long column, out long row);
		public Vte.CursorShape get_cursor_shape ();
		[Version (since = "0.58")]
		public bool get_enable_bidi ();
		[Version (since = "0.64")]
		public bool get_enable_fallback_scrolling ();
		[Version (since = "0.58")]
		public bool get_enable_shaping ();
		[Version (since = "0.62")]
		public bool get_enable_sixel ();
		[Version (deprecated = true, deprecated_since = "0.54")]
		public unowned string? get_encoding ();
		public unowned Pango.FontDescription get_font ();
		public double get_font_scale ();
		public bool get_has_selection ();
		[Version (deprecated = true, deprecated_since = "0.54")]
		public unowned string? get_icon_title ();
		public bool get_input_enabled ();
		public bool get_mouse_autohide ();
		public unowned Vte.Pty get_pty ();
		[Version (deprecated = true, deprecated_since = "0.58")]
		public bool get_rewrap_on_resize ();
		public long get_row_count ();
		[Version (since = "0.52")]
		public bool get_scroll_on_keystroke ();
		[Version (since = "0.52")]
		public bool get_scroll_on_output ();
		[Version (since = "0.66")]
		public bool get_scroll_unit_is_pixels ();
		[Version (since = "0.52")]
		public long get_scrollback_lines ();
		public string? get_text ([CCode (delegate_target_pos = 1.5)] Vte.SelectionFunc? is_selected, out GLib.Array<Vte.CharAttributes?>? attributes);
		[Version (since = "0.52")]
		public Vte.TextBlinkMode get_text_blink_mode ();
		[Version (deprecated = true, deprecated_since = "0.56")]
		public string get_text_include_trailing_spaces ([CCode (delegate_target_pos = 1.5)] Vte.SelectionFunc? is_selected, out GLib.Array<Vte.CharAttributes?> attributes);
		public string? get_text_range (long start_row, long start_col, long end_row, long end_col, [CCode (delegate_target_pos = 5.5)] Vte.SelectionFunc? is_selected, out GLib.Array<Vte.CharAttributes?>? attributes);
		[Version (since = "0.72")]
		public string? get_text_range_format (Vte.Format format, long start_row, long start_col, long end_row, long end_col, size_t length);
		[Version (since = "0.70")]
		public string? get_text_selected (Vte.Format format);
		[Version (since = "0.72")]
		public string? get_text_selected_full (Vte.Format format, out size_t length);
		public unowned string? get_window_title ();
		[Version (since = "0.40")]
		public unowned string? get_word_char_exceptions ();
		[Version (since = "0.72")]
		public Vte.Align get_xalign ();
		[Version (since = "0.72")]
		public bool get_xfill ();
		[Version (since = "0.72")]
		public Vte.Align get_yalign ();
		[Version (since = "0.72")]
		public bool get_yfill ();
		[Version (since = "0.46")]
		public int match_add_regex (Vte.Regex regex, uint32 flags);
		[Version (deprecated = true, deprecated_since = "0.46")]
		public string? match_check (long column, long row, out int tag);
		public void match_remove (int tag);
		public void match_remove_all ();
		[Version (deprecated = true, deprecated_since = "0.40")]
		public void match_set_cursor (int tag, Gdk.Cursor? cursor);
		public void match_set_cursor_name (int tag, string cursor_name);
		public void paste_primary ();
		[Version (since = "0.68")]
		public void paste_text (string text);
		public Vte.Pty pty_new_sync (Vte.PtyFlags flags, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public void reset (bool clear_tabstops, bool clear_history);
		public bool search_find_next ();
		public bool search_find_previous ();
		[Version (since = "0.46")]
		public unowned Vte.Regex search_get_regex ();
		public bool search_get_wrap_around ();
		[Version (since = "0.46")]
		public void search_set_regex (Vte.Regex? regex, uint32 flags);
		public void search_set_wrap_around (bool wrap_around);
		public void select_all ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public void set_allow_bold (bool allow_bold);
		[Version (since = "0.50")]
		public void set_allow_hyperlink (bool allow_hyperlink);
		public void set_audible_bell (bool is_audible);
		public void set_backspace_binding (Vte.EraseBinding binding);
		[Version (since = "0.52")]
		public void set_bold_is_bright (bool bold_is_bright);
		[Version (since = "0.52")]
		public void set_cell_height_scale (double scale);
		[Version (since = "0.52")]
		public void set_cell_width_scale (double scale);
		public void set_cjk_ambiguous_width (int width);
		[Version (since = "0.52")]
		public void set_clear_background (bool setting);
		public void set_color_background (Gdk.RGBA background);
		public void set_color_bold (Gdk.RGBA? bold);
		public void set_color_cursor (Gdk.RGBA? cursor_background);
		[Version (since = "0.44")]
		public void set_color_cursor_foreground (Gdk.RGBA? cursor_foreground);
		public void set_color_foreground (Gdk.RGBA foreground);
		public void set_color_highlight (Gdk.RGBA? highlight_background);
		public void set_color_highlight_foreground (Gdk.RGBA? highlight_foreground);
		public void set_colors (Gdk.RGBA? foreground, Gdk.RGBA? background, [CCode (array_length_cname = "palette_size", array_length_pos = 3.1, array_length_type = "gsize")] Gdk.RGBA[]? palette);
		public void set_cursor_blink_mode (Vte.CursorBlinkMode mode);
		public void set_cursor_shape (Vte.CursorShape shape);
		public void set_default_colors ();
		public void set_delete_binding (Vte.EraseBinding binding);
		[Version (since = "0.58")]
		public void set_enable_bidi (bool enable_bidi);
		[Version (since = "0.64")]
		public void set_enable_fallback_scrolling (bool enable);
		[Version (since = "0.58")]
		public void set_enable_shaping (bool enable_shaping);
		[Version (since = "0.62")]
		public void set_enable_sixel (bool enabled);
		[Version (deprecated = true, deprecated_since = "0.54")]
		public bool set_encoding (string? codeset) throws GLib.Error;
		public void set_font (Pango.FontDescription? font_desc);
		public void set_font_scale (double scale);
		public void set_input_enabled (bool enabled);
		public void set_mouse_autohide (bool setting);
		public void set_pty (Vte.Pty? pty);
		[Version (deprecated = true, deprecated_since = "0.58")]
		public void set_rewrap_on_resize (bool rewrap);
		public void set_scroll_on_keystroke (bool scroll);
		public void set_scroll_on_output (bool scroll);
		[Version (since = "0.66")]
		public void set_scroll_unit_is_pixels (bool enable);
		public void set_scrollback_lines (long lines);
		public void set_size (long columns, long rows);
		[Version (since = "0.52")]
		public void set_text_blink_mode (Vte.TextBlinkMode text_blink_mode);
		[Version (since = "0.40")]
		public void set_word_char_exceptions (string exceptions);
		[Version (since = "0.72")]
		public void set_xalign (Vte.Align align);
		[Version (since = "0.72")]
		public void set_xfill (bool fill);
		[Version (since = "0.72")]
		public void set_yalign (Vte.Align align);
		[Version (since = "0.72")]
		public void set_yfill (bool fill);
		[Version (since = "0.48")]
		public void spawn_async (Vte.PtyFlags pty_flags, string? working_directory, [CCode (array_length = false, array_null_terminated = true)] string[] argv, [CCode (array_length = false, array_null_terminated = true)] string[]? envv, GLib.SpawnFlags spawn_flags, [CCode (delegate_target_pos = 6.33333, destroy_notify_pos = 6.66667)] owned GLib.SpawnChildSetupFunc? child_setup, int timeout, GLib.Cancellable? cancellable, [CCode (scope = "async")] Vte.TerminalSpawnAsyncCallback? callback);
		[Version (deprecated = true, deprecated_since = "0.48")]
		public bool spawn_sync (Vte.PtyFlags pty_flags, string? working_directory, [CCode (array_length = false, array_null_terminated = true)] string[] argv, [CCode (array_length = false, array_null_terminated = true)] string[]? envv, GLib.SpawnFlags spawn_flags, [CCode (delegate_target_pos = 6.5)] GLib.SpawnChildSetupFunc? child_setup, out GLib.Pid child_pid, GLib.Cancellable? cancellable = null) throws GLib.Error;
		[Version (since = "0.62")]
		public void spawn_with_fds_async (Vte.PtyFlags pty_flags, string? working_directory, [CCode (array_length = false, array_null_terminated = true)] string[] argv, [CCode (array_length = false, array_null_terminated = true)] string[]? envv, [CCode (array_length_cname = "n_fds", array_length_pos = 5.5)] int[]? fds, [CCode (array_length_cname = "n_map_fds", array_length_pos = 6.5)] int[]? map_fds, GLib.SpawnFlags spawn_flags, [CCode (delegate_target_pos = 8.33333, destroy_notify_pos = 8.66667)] owned GLib.SpawnChildSetupFunc? child_setup, int timeout, GLib.Cancellable? cancellable, [CCode (scope = "async")] Vte.TerminalSpawnAsyncCallback? callback);
		public void unselect_all ();
		public void watch_child (GLib.Pid child_pid);
		public bool write_contents_sync (GLib.OutputStream stream, Vte.WriteFlags flags, GLib.Cancellable? cancellable = null) throws GLib.Error;
		[Version (deprecated = true, deprecated_since = "0.60")]
		public bool allow_bold { get; set; }
		[Version (since = "0.50")]
		public bool allow_hyperlink { get; set; }
		public bool audible_bell { get; set; }
		[NoAccessorMethod]
		public Vte.EraseBinding backspace_binding { get; set; }
		[Version (since = "0.52")]
		public bool bold_is_bright { get; set; }
		[Version (since = "0.52")]
		public double cell_height_scale { get; set; }
		[Version (since = "0.52")]
		public double cell_width_scale { get; set; }
		public int cjk_ambiguous_width { get; set; }
		public string current_directory_uri { get; }
		public string current_file_uri { get; }
		public Vte.CursorBlinkMode cursor_blink_mode { get; set; }
		public Vte.CursorShape cursor_shape { get; set; }
		[NoAccessorMethod]
		public Vte.EraseBinding delete_binding { get; set; }
		[Version (since = "0.58")]
		public bool enable_bidi { get; set; }
		public bool enable_fallback_scrolling { get; set; }
		[Version (since = "0.58")]
		public bool enable_shaping { get; set; }
		[Version (since = "0.62")]
		public bool enable_sixel { get; set; }
		[NoAccessorMethod]
		[Version (deprecated = true, deprecated_since = "0.54")]
		public string encoding { owned get; set; }
		[NoAccessorMethod]
		public Pango.FontDescription font_desc { owned get; set; }
		public double font_scale { get; set; }
		[NoAccessorMethod]
		[Version (since = "0.50")]
		public string hyperlink_hover_uri { owned get; }
		[Version (deprecated = true, deprecated_since = "0.54")]
		public string icon_title { get; }
		public bool input_enabled { get; set; }
		[NoAccessorMethod]
		public bool pointer_autohide { get; set; }
		public Vte.Pty pty { get; set; }
		[Version (deprecated = true, deprecated_since = "0.58")]
		public bool rewrap_on_resize { get; set; }
		public bool scroll_on_keystroke { get; set; }
		public bool scroll_on_output { get; set; }
		[Version (since = "0.66")]
		public bool scroll_unit_is_pixels { get; set; }
		public uint scrollback_lines { get; set; }
		[Version (since = "0.52")]
		public Vte.TextBlinkMode text_blink_mode { get; set; }
		public string window_title { get; }
		[Version (since = "0.40")]
		public string word_char_exceptions { get; }
		[Version (since = "0.72")]
		public Vte.Align xalign { get; set; }
		[Version (since = "0.72")]
		public bool xfill { get; set; }
		[Version (since = "0.72")]
		public Vte.Align yalign { get; set; }
		[Version (since = "0.72")]
		public bool yfill { get; set; }
		public virtual signal void bell ();
		public virtual signal void char_size_changed (uint char_width, uint char_height);
		public virtual signal void child_exited (int status);
		public virtual signal void commit (string text, uint size);
		public virtual signal void contents_changed ();
		[HasEmitter]
		public virtual signal void copy_clipboard ();
		public signal void current_directory_uri_changed ();
		public signal void current_file_uri_changed ();
		public virtual signal void cursor_moved ();
		public virtual signal void decrease_font_size ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void deiconify_window ();
		public virtual signal void encoding_changed ();
		public virtual signal void eof ();
		[Version (since = "0.50")]
		public signal void hyperlink_hover_uri_changed (string uri, Gdk.Rectangle bbox);
		[Version (deprecated = true, deprecated_since = "0.54")]
		public virtual signal void icon_title_changed ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void iconify_window ();
		public virtual signal void increase_font_size ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void lower_window ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void maximize_window ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void move_window (uint x, uint y);
		[HasEmitter]
		public virtual signal void paste_clipboard ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void raise_window ();
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void refresh_window ();
		public virtual signal void resize_window (uint width, uint height);
		[Version (deprecated = true, deprecated_since = "0.60")]
		public virtual signal void restore_window ();
		public virtual signal void selection_changed ();
		public virtual signal void window_title_changed ();
	}
	[CCode (cheader_filename = "vte/vte.h", has_type_id = false)]
	[Version (deprecated = true, deprecated_since = "0.68")]
	public struct CharAttributes {
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_ALIGN_", type_id = "vte_align_get_type ()")]
	[Version (since = "0.68")]
	public enum Align {
		START,
		CENTER,
		END
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_CURSOR_BLINK_", type_id = "vte_cursor_blink_mode_get_type ()")]
	public enum CursorBlinkMode {
		SYSTEM,
		ON,
		OFF
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_CURSOR_SHAPE_", type_id = "vte_cursor_shape_get_type ()")]
	public enum CursorShape {
		BLOCK,
		IBEAM,
		UNDERLINE
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_ERASE_", type_id = "vte_erase_binding_get_type ()")]
	public enum EraseBinding {
		AUTO,
		ASCII_BACKSPACE,
		ASCII_DELETE,
		DELETE_SEQUENCE,
		TTY
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_FEATURE_", has_type_id = false)]
	[Flags]
	[Version (since = "0.62")]
	public enum FeatureFlags {
		FLAG_BIDI,
		FLAG_ICU,
		FLAG_SYSTEMD,
		FLAG_SIXEL,
		FLAGS_MASK
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_FORMAT_", type_id = "vte_format_get_type ()")]
	[Version (since = "0.50")]
	public enum Format {
		TEXT,
		HTML
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_PTY_", type_id = "vte_pty_flags_get_type ()")]
	[Flags]
	public enum PtyFlags {
		NO_LASTLOG,
		NO_UTMP,
		NO_WTMP,
		NO_HELPER,
		NO_FALLBACK,
		NO_SESSION,
		NO_CTTY,
		DEFAULT
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_TEXT_BLINK_", type_id = "vte_text_blink_mode_get_type ()")]
	[Version (since = "0.52")]
	public enum TextBlinkMode {
		NEVER,
		FOCUSED,
		UNFOCUSED,
		ALWAYS
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_WRITE_", type_id = "vte_write_flags_get_type ()")]
	public enum WriteFlags {
		DEFAULT
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_PTY_ERROR_", type_id = "vte_pty_error_get_type ()")]
	public errordomain PtyError {
		PTY_HELPER_FAILED,
		PTY98_FAILED;
		public static GLib.Quark quark ();
	}
	[CCode (cheader_filename = "vte/vte.h", cprefix = "VTE_REGEX_ERROR_", type_id = "vte_regex_error_get_type ()")]
	[Version (since = "0.46")]
	public errordomain RegexError {
		INCOMPATIBLE,
		NOT_SUPPORTED;
		public static GLib.Quark quark ();
	}
	[CCode (cheader_filename = "vte/vte.h", instance_pos = 3.9)]
	public delegate bool SelectionFunc (Vte.Terminal terminal, long column, long row);
	[CCode (cheader_filename = "vte/vte.h", instance_pos = 3.9)]
	[Version (since = "0.48")]
	public delegate void TerminalSpawnAsyncCallback (Vte.Terminal terminal, GLib.Pid pid, GLib.Error error);
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_MAJOR_VERSION")]
	public const int MAJOR_VERSION;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_MICRO_VERSION")]
	public const int MICRO_VERSION;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_MINOR_VERSION")]
	public const int MINOR_VERSION;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_REGEX_FLAGS_DEFAULT")]
	public const int REGEX_FLAGS_DEFAULT;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_SPAWN_NO_PARENT_ENVV")]
	public const int SPAWN_NO_PARENT_ENVV;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_SPAWN_NO_SYSTEMD_SCOPE")]
	[Version (since = "0.60")]
	public const int SPAWN_NO_SYSTEMD_SCOPE;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_SPAWN_REQUIRE_SYSTEMD_SCOPE")]
	[Version (since = "0.60")]
	public const int SPAWN_REQUIRE_SYSTEMD_SCOPE;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_TEST_FLAGS_ALL")]
	public const uint64 TEST_FLAGS_ALL;
	[CCode (cheader_filename = "vte/vte.h", cname = "VTE_TEST_FLAGS_NONE")]
	public const uint64 TEST_FLAGS_NONE;
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (deprecated = true, deprecated_since = "0.60", since = "0.60")]
	public static bool get_encoding_supported (string encoding);
	[CCode (array_length = false, array_null_terminated = true, cheader_filename = "vte/vte.h")]
	[Version (deprecated = true, deprecated_since = "0.60", since = "0.60")]
	public static string[] get_encodings (bool include_aliases);
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (since = "0.62")]
	public static Vte.FeatureFlags get_feature_flags ();
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (since = "0.40")]
	public static unowned string get_features ();
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (since = "0.40")]
	public static uint get_major_version ();
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (since = "0.40")]
	public static uint get_micro_version ();
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (since = "0.40")]
	public static uint get_minor_version ();
	[CCode (cheader_filename = "vte/vte.h")]
	public static string get_user_shell ();
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (replacement = "PtyError.quark")]
	public static GLib.Quark pty_error_quark ();
	[CCode (cheader_filename = "vte/vte.h")]
	[Version (replacement = "RegexError.quark")]
	public static GLib.Quark regex_error_quark ();
}
