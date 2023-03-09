if gnome.found()
    subdir('data')
    scriptdir_sources = [
        'scriptdir.vala',
        scriptdir_resources,
    ]
    c_args = ['-DG_LOG_DOMAIN="scriptdir"']
    tgts += shared_module(
        'scriptdir',
        scriptdir_sources,
        c_args: c_args,
        dependencies: dependencies,
        include_directories: inc,
        install: true,
        install_dir: install_dir,
    )
endif
