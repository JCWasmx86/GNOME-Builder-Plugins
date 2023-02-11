config = configuration_data()
config.set('BUILDER_ABI', get_option('builder_abi'))
foreach e : plugins
    configure_file(
        input: e,
        output: e,
        configuration: config,
        install: true,
        install_dir: install_dir,
    )
endforeach

