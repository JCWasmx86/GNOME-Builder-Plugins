[CCode (cprefix = "Peas", gir_namespace = "Peas", gir_version = "2", lower_case_cprefix = "peas_")]
namespace Peas {
	[CCode (cheader_filename = "libpeas.h", type_id = "peas_engine_get_type ()")]
	public sealed class Engine : GLib.Object, GLib.ListModel {
		[CCode (has_construct_function = false)]
		public Engine ();
		public void add_search_path (string module_dir, string? data_dir);
		public GLib.Object create_extension_with_properties (Peas.PluginInfo info, GLib.Type extension_type, [CCode (array_length_cname = "n_properties", array_length_pos = 2.5, array_length_type = "guint")] string[] prop_names, [CCode (array_length_cname = "n_properties", array_length_pos = 2.5, array_length_type = "guint")] GLib.Value[] prop_values);
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] dup_loaded_plugins ();
		public void enable_loader (string loader_name);
		public void garbage_collect ();
		public static unowned Peas.Engine get_default ();
		public unowned Peas.PluginInfo get_plugin_info (string plugin_name);
		public bool provides_extension (Peas.PluginInfo info, GLib.Type extension_type);
		public void rescan_plugins ();
		public void set_loaded_plugins ([CCode (array_length = false, array_null_terminated = true)] string[]? plugin_names);
		[CCode (has_construct_function = false)]
		public Engine.with_nonglobal_loaders ();
		[CCode (array_length = false, array_null_terminated = true)]
		[NoAccessorMethod]
		public string[] loaded_plugins { owned get; set; }
		[NoAccessorMethod]
		public bool nonglobal_loaders { get; construct; }
		[HasEmitter]
		public signal void load_plugin (Peas.PluginInfo info);
		[HasEmitter]
		public signal void unload_plugin (Peas.PluginInfo info);
	}
	[CCode (cheader_filename = "libpeas.h", type_id = "peas_extension_base_get_type ()")]
	public abstract class ExtensionBase : GLib.Object {
		[CCode (has_construct_function = false)]
		protected ExtensionBase ();
		public string get_data_dir ();
		public unowned Peas.PluginInfo get_plugin_info ();
		public string data_dir { owned get; }
		public Peas.PluginInfo plugin_info { get; construct; }
	}
	[CCode (cheader_filename = "libpeas.h", type_id = "peas_extension_set_get_type ()")]
	public sealed class ExtensionSet : GLib.Object, GLib.ListModel {
		[CCode (has_construct_function = false)]
		protected ExtensionSet ();
		public void @foreach (Peas.ExtensionSetForeachFunc func);
		public unowned GLib.Object? get_extension (Peas.PluginInfo info);
		[CCode (has_construct_function = false)]
		public ExtensionSet.with_properties (Peas.Engine? engine, GLib.Type exten_type, [CCode (array_length_cname = "n_properties", array_length_pos = 2.5, array_length_type = "guint")] string[] prop_names, [CCode (array_length_cname = "n_properties", array_length_pos = 2.5, array_length_type = "guint")] GLib.Value[] prop_values);
		[NoAccessorMethod]
		public void* construct_properties { construct; }
		[NoAccessorMethod]
		public Peas.Engine engine { owned get; construct; }
		[NoAccessorMethod]
		public GLib.Type extension_type { get; construct; }
		public signal void extension_added (Peas.PluginInfo info, GLib.Object extension);
		public signal void extension_removed (Peas.PluginInfo info, GLib.Object extension);
	}
	[CCode (cheader_filename = "libpeas.h", type_id = "peas_object_module_get_type ()")]
	public class ObjectModule : GLib.TypeModule, GLib.TypePlugin {
		[CCode (has_construct_function = false)]
		protected ObjectModule ();
		public void register_extension_factory (GLib.Type exten_type, owned Peas.FactoryFunc factory_func);
		public void register_extension_type (GLib.Type exten_type, GLib.Type impl_type);
		[NoAccessorMethod]
		public bool local_linkage { get; construct; }
		[NoAccessorMethod]
		public string module_name { owned get; construct; }
		[NoAccessorMethod]
		public string path { owned get; construct; }
		[NoAccessorMethod]
		public bool resident { get; construct; }
		[NoAccessorMethod]
		public string symbol { owned get; construct; }
	}
	[CCode (cheader_filename = "libpeas.h", type_id = "peas_plugin_info_get_type ()")]
	public sealed class PluginInfo : GLib.Object {
		[CCode (has_construct_function = false)]
		protected PluginInfo ();
		public static GLib.Quark error_quark ();
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[] get_authors ();
		public unowned string get_copyright ();
		public unowned string get_data_dir ();
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[] get_dependencies ();
		public unowned string get_description ();
		[Version (since = "1.6")]
		public unowned string? get_external_data (string key);
		public unowned string get_help_uri ();
		public unowned string get_icon_name ();
		public unowned string get_module_dir ();
		public unowned string get_module_name ();
		public unowned string get_name ();
		public GLib.Resource get_resource (string? filename) throws GLib.Error;
		[Version (since = "1.4")]
		public GLib.Settings? get_settings (string? schema_id);
		public unowned string get_version ();
		public unowned string get_website ();
		public bool has_dependency (string module_name);
		public bool is_available () throws GLib.Error;
		public bool is_builtin ();
		public bool is_hidden ();
		public bool is_loaded ();
		public void load_resource (string? filename) throws GLib.Error;
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] authors { get; }
		[NoAccessorMethod]
		public bool builtin { get; }
		public string copyright { get; }
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] dependencies { get; }
		public string description { get; }
		public string help_uri { get; }
		[NoAccessorMethod]
		public bool hidden { get; }
		public string icon_name { get; }
		[NoAccessorMethod]
		public bool loaded { get; }
		public string module_dir { get; }
		public string module_name { get; }
		public string name { get; }
		public string version { get; }
		public string website { get; }
	}
	[CCode (cheader_filename = "libpeas.h", cprefix = "PEAS_PLUGIN_INFO_ERROR_", has_type_id = false)]
	public enum PluginInfoError {
		LOADING_FAILED,
		LOADER_NOT_FOUND,
		DEP_NOT_FOUND,
		DEP_LOADING_FAILED
	}
	[CCode (cheader_filename = "libpeas.h", has_target = false)]
	public delegate void ExtensionSetForeachFunc (Peas.ExtensionSet @set, Peas.PluginInfo info, GLib.Object extension, void* data);
	[CCode (cheader_filename = "libpeas.h", instance_pos = 1.9)]
	public delegate GLib.Object FactoryFunc ([CCode (array_length_cname = "n_parameters", array_length_pos = 0.5, array_length_type = "guint")] GLib.Parameter[] parameters);
}
