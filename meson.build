project('builder_plugins', 'vala', 'c',
	version: '0.1.0',
	meson_version: '>= 0.59.0',
)

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
inc_dir = meson.project_source_root() / 'include'
inc = include_directories (
	'include/libide/code',
	'include/libide/core',
	'include/libide/io',
	'include/libide/threading',
	'include/libide/debugger',
	'include/libide/foundry',
	'include/libide/editor',
	'include/libide/gui',
	'include/libide/gtk',
	'include/libide/projects',
	'include/libide/tree',
	'include/libide/search',
	'include/libide/vcs',
	'include/libide/sourceview',
	'include/libide/greeter',
	'include/libide/lsp',
	'include/libide/plugins',
	'include/libide/terminal',
	'include/libide/webkit',
	'include/template-glib-1.0',
	'include/libpanel-1',
	'include/vte-2.91',
)
dependencies = [
	dependency('gobject-2.0'),
	dependency('glib-2.0'),
	dependency('gee-0.8'),
	dependency('json-glib-1.0'),
	meson.get_compiler('vala').find_library('ide', dirs: vapi_dir),
	dependency('gtk4'),
	dependency('gtksourceview-5'),
	dependency('libadwaita-1'),
	meson.get_compiler('vala').find_library('vte-3.91', dirs: vapi_dir),
	dependency('libpeas-1.0'),
	meson.get_compiler('vala').find_library('panel-1', dirs: vapi_dir),
	meson.get_compiler('vala').find_library('template-1.0', dirs: vapi_dir),
]
gnome = import('gnome')
subdir('cabal')
subdir('clangd')
subdir('data')
subdir('hls')
subdir('icon_installer')
subdir('meson')
subdir('shellcheck')
subdir('shfmt')
subdir('stack')