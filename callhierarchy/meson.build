if gnome.found()
    subdir('data')
    callhierarchy_sources = ['callhierarchy.vala', 'wrap.c', callhierarchy_resources]
    c_args = ['-DG_LOG_DOMAIN="callhierarchy"']
    tgts += shared_module(
        'callhierarchy',
        callhierarchy_sources,
        c_args: c_args,
        dependencies: dependencies,
        include_directories: inc,
        install: true,
        install_dir: install_dir,
    )
endif

