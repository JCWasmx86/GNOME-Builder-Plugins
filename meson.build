project('builder_plugins', 'vala', 'c',
	version: '0.1.0',
	meson_version: '>= 0.60.0',
)
c = run_command('whoami', check: true)
assert (c.returncode () == 0, 'whoami failed????')
user_name = c.stdout().strip()
if user_name == 'root'
	warning('Don\'t run as root!')
	install_dir='/root/.local/share/gnome-builder/plugins'
else
	install_dir='/home' / user_name / '.local/share/gnome-builder/plugins'
endif
vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments(['-g3', '-gz=zlib'], language: 'c')

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
	'include/libide/tweaks',
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
	meson.get_compiler('vala').find_library('template-glib-1.0', dirs: vapi_dir),
]
gnome = import('gnome')
plugins = []

if get_option('plugin_cabal').enabled()
	subdir('cabal')
	plugins += 'cabal.plugin'
endif
if get_option('plugin_clangd').enabled()
	subdir('clangd')
	plugins += 'clangd.plugin'
endif

if get_option('plugin_hls').enabled()
	subdir('hls')
	plugins += 'hls.plugin'
endif
if get_option('plugin_icon_installer').enabled()
	subdir('icon_installer')
	plugins += 'icon_installer.plugin'
endif
if get_option('plugin_meson').enabled()
	subdir('meson')
	plugins += 'mesonlsp.plugin'
endif
if get_option('plugin_pylint').enabled()
	subdir('pylint')
	plugins += 'pylint.plugin'
endif
if get_option('plugin_shellcheck').enabled()
	subdir('shellcheck')
	plugins += 'shellcheck.plugin'
endif
if get_option('plugin_shfmt').enabled()
	subdir('shfmt')
	plugins += 'shfmt.plugin'
endif
if get_option('plugin_sourcekit').enabled()
	subdir('sourcekit')
	plugins += 'sourcekit.plugin'
endif
if get_option('plugin_sqlconnections').enabled()
	subdir('sqlconnections')
	plugins += 'sqlconnections.plugin'
endif
if get_option('plugin_sqls').enabled()
	subdir('sqls')
	plugins += 'sqls.plugin'
endif
if get_option('plugin_stack').enabled()
	subdir('stack')
	plugins += 'stack.plugin'
endif
if get_option('plugin_swift').enabled()
	subdir('swift')
	plugins += 'swift.plugin'
endif
if get_option('plugin_swift_format').enabled()
	subdir('swift-format')
	plugins += 'swift-format.plugin'
endif
if get_option('plugin_swift_lint').enabled()
	subdir('swift-lint')
	plugins += 'swift-lint.plugin'
endif
if get_option('plugin_texlab').enabled()
	subdir('texlab')
	plugins += 'texlab.plugin'
endif
if get_option('plugin_xmlfmt').enabled()
	subdir('xmlfmt')
	plugins += 'xmlfmt.plugin'
endif

subdir('data')
