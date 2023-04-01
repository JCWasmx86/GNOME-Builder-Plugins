project(
    'builder_plugins',
    'vala',
    'c',
    version: '0.1.0',
    meson_version: '>= 0.60.0',
)
c = run_command('whoami', check: true)
assert(c.returncode() == 0, 'whoami failed????')
user_name = c.stdout().strip()
if user_name == 'root'
    warning('Don\'t run as root!')
    install_dir = '/root/.local/share/gnome-builder/plugins'
else
    install_dir = '/home' / user_name / '.local/share/gnome-builder/plugins'
endif
vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments(['-g3', '-I', '/app/include/template-glib-1.0'], language: 'c')

inc = include_directories(
    'include/libdex-1',
    'include/libide',
    'include/libide/code',
    'include/libide/core',
    'include/libide/debugger',
    'include/libide/editor',
    'include/libide/foundry',
    'include/libide/greeter',
    'include/libide/gtk',
    'include/libide/gui',
    'include/libide/io',
    'include/libide/lsp',
    'include/libide/plugins',
    'include/libide/projects',
    'include/libide/search',
    'include/libide/sourceview',
    'include/libide/terminal',
    'include/libide/threading',
    'include/libide/tree',
    'include/libide/tweaks',
    'include/libide/vcs',
    'include/libide/webkit',
    'include/libpanel-1',
    'include/libpeas',
    'include/vte-2.91',
    'include/webkitgtk-6.0',
)
vala_compiler = meson.get_compiler('vala')
dependencies = [
    dependency('gee-0.8'),
    dependency('gio-2.0'),
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk4'),
    dependency('gtksourceview-5'),
    dependency('json-glib-1.0'),
    dependency('libadwaita-1', version: '>=1.2.0'),
    dependency('libsoup-3.0'),
    vala_compiler.find_library('ide', dirs: vapi_dir),
    vala_compiler.find_library('libdex', dirs: vapi_dir),
    vala_compiler.find_library('linux'),
    vala_compiler.find_library('panel-1', dirs: vapi_dir),
    vala_compiler.find_library('peas', dirs: vapi_dir),
    vala_compiler.find_library('template-glib-1.0', dirs: vapi_dir),
    vala_compiler.find_library('vte-3.91', dirs: vapi_dir),
]

gnome = import('gnome', required: false)
plugins = []
tgts = []
enabled_plugins = []

if get_option('smart').enabled()
    enabled_plugins += 'icon_installer'
    enabled_plugins += 'gitgui'
    progs = [
        'clangd',
        'shfmt',
        'texlab',
        'scriptdir',
    ]
    foreach prog : progs
        p = find_program(prog, required: false)
        if p.found()
            enabled_plugins += prog
        endif
    endforeach
    spec_progs = {
        'Swift-MesonLSP': 'meson',
        'swift': 'swift-templates',
    }
    foreach prog, plugin : spec_progs
        p = find_program(prog, required: false)
        if p.found()
            enabled_plugins += plugin
        endif
    endforeach
    foreach x : enabled_plugins
        subdir(x)
        plugins += (x + '.plugin')
    endforeach
else
    if get_option('plugin_clangd').enabled()
        subdir('clangd')
        plugins += 'clangd.plugin'
    endif
    if get_option('plugin_gitgui').enabled()
        subdir('gitgui')
        plugins += 'gitgui.plugin'
    endif
    if get_option('plugin_icon_installer').enabled()
        subdir('icon_installer')
        plugins += 'icon_installer.plugin'
    endif
    if get_option('plugin_meson').enabled()
        subdir('meson')
        plugins += 'meson.plugin'
    endif
    if get_option('plugin_scriptdir').enabled()
        subdir('scriptdir')
        plugins += 'scriptdir.plugin'
    endif
    if get_option('plugin_shfmt').enabled()
        subdir('shfmt')
        plugins += 'shfmt.plugin'
    endif
    if get_option('plugin_swift_templates').enabled()
        subdir('swift-templates')
        plugins += 'swift-templates.plugin'
    endif
    if get_option('plugin_texlab').enabled()
        subdir('texlab')
        plugins += 'texlab.plugin'
    endif
endif

subdir('data')
copied_tgts = []
cp = find_program('cp')
compress = find_program('eu-elfcompress', required: false)
if compress.found() and get_option('compress').enabled()
    foreach tgt : tgts
        name = tgt.full_path().split('/')[-1]
        copied_tgts += custom_target(
            'compress_' + name,
            output: name,
            input: tgt,
            command: [compress, '@INPUT@', '-o', '@OUTPUT@', '-q'],
            install: false,
        )
    endforeach
else
    foreach tgt : tgts
        name = tgt.full_path().split('/')[-1]
        copied_tgts += custom_target(
            'copy_' + name,
            output: name,
            input: tgt,
            command: [cp, '@INPUT@', '@OUTPUT@'],
            install: false,
        )
    endforeach
endif

foreach p : plugins
    # TODO: Source item ... cannot be converted to File object, because it is a generated file
    plugin_file = meson.current_build_dir() + '/data/' + p
    copied_tgts += custom_target(
        'copy_' + p,
        output: p,
        input: plugin_file,
        command: [cp, '@INPUT@', '@OUTPUT@'],
        install: false,
    )
endforeach

zip = find_program('zip')
custom_target(
    'make_dist',
    output: 'dist.zip',
    input: copied_tgts,
    command: [zip, '--quiet', '@OUTPUT@', '@INPUT@'],
    install: false,
    build_by_default: true,
)

