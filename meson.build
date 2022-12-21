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
add_project_arguments(['-g3'], language: 'c')

inc = include_directories(
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
    'include/libpanel-1',
    'include/vte-2.91',
)
dependencies = [
    dependency('gee-0.8'),
    dependency('gio-2.0'),
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk4'),
    dependency('gtksourceview-5'),
    dependency('json-glib-1.0'),
    dependency('libadwaita-1', version: '>=1.2.0'),
    dependency('libpeas-1.0'),
    dependency('template-glib-1.0'),
    meson.get_compiler('vala').find_library('ide', dirs: vapi_dir),
    meson.get_compiler('vala').find_library('panel-1', dirs: vapi_dir),
    meson.get_compiler('vala').find_library('vte-3.91', dirs: vapi_dir),
    meson.get_compiler('vala').find_library('linux'),
]

gnome = import('gnome')
plugins = []
tgts = []
enabled_plugins = []

if get_option('smart').enabled()
    enabled_plugins += 'icon_installer'
    enabled_plugins += 'xmlfmt'
    enabled_plugins += 'markdown'
    enabled_plugins += 'gitgui'
    if get_option('experimental')
        enabled_plugins += 'sqlconnections'
    endif
    progs = [
        'cabal',
        'clangd',
        'hadolint',
        'muon',
        'pylint',
        'shfmt',
        'sqls',
        'stack',
        'swift',
        'texlab',
    ]
    foreach prog : progs
        p = find_program(prog, required: false)
        if p.found()
            enabled_plugins += prog
        endif
    endforeach
    spec_progs = {
        'haskell-language-server-wrapper1': 'hls',
        'meson_lsp': 'meson',
        'sourcekit-lsp': 'sourcekit',
        'swift-format': 'swift-format',
        'swift': 'swift-templates',
        'swiftlint': 'swift-lint',
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
    if get_option('plugin_cabal').enabled()
        subdir('cabal')
        plugins += 'cabal.plugin'
    endif
    if get_option('plugin_clangd').enabled()
        subdir('clangd')
        plugins += 'clangd.plugin'
    endif
    if get_option('plugin_gitgui').enabled()
        subdir('gitgui')
        plugins += 'gitgui.plugin'
    endif
    if get_option('plugin_hadolint').enabled()
        subdir('hadolint')
        plugins += 'hadolint.plugin'
    endif
    if get_option('plugin_hls').enabled()
        subdir('hls')
        plugins += 'hls.plugin'
    endif
    if get_option('plugin_icon_installer').enabled()
        subdir('icon_installer')
        plugins += 'icon_installer.plugin'
    endif
    if get_option('plugin_markdown').enabled()
        subdir('markdown')
        plugins += 'markdown.plugin'
    endif
    if get_option('plugin_meson').enabled()
        subdir('meson')
        plugins += 'meson.plugin'
    endif
    if get_option('plugin_muon').enabled()
        subdir('muon')
        plugins += 'muon.plugin'
    endif
    if get_option('plugin_pylint').enabled()
        subdir('pylint')
        plugins += 'pylint.plugin'
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
    if get_option('plugin_swift_templates').enabled()
        subdir('swift-templates')
        plugins += 'swift-templates.plugin'
    endif
    if get_option('plugin_texlab').enabled()
        subdir('texlab')
        plugins += 'texlab.plugin'
    endif
    if get_option('plugin_xmlfmt').enabled()
        subdir('xmlfmt')
        plugins += 'xmlfmt.plugin'
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
