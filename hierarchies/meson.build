if gnome.found()
    subdir('data')
    hierarchies_sources = ['hierarchies.vala', 'wrap.c', hierarchies_resources]
    c_args = ['-DG_LOG_DOMAIN="hierarchies"']
    tgts += shared_module(
        'hierarchies',
        hierarchies_sources,
        c_args: c_args,
        dependencies: dependencies,
        include_directories: inc,
        install: true,
        install_dir: install_dir,
    )
endif

