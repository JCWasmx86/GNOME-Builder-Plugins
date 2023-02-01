config = configuration_data()
config.set('BUILDER_ABI', get_option('builder_abi'))
if 'meson.plugin' in plugins and use_swift_meson_lsp
    config.set(
        'EXTRA_LINE',
        'X-Formatter-Languages=meson\nX-Completion-Provider-Languages=meson',
    )
else
    config.set('EXTRA_LINE', '')
endif
foreach e : plugins
    configure_file(
        input: e,
        output: e,
        configuration: config,
        install: true,
        install_dir: install_dir,
    )
endforeach

