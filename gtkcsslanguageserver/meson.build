gtkcsslanguageserver_sources = ['gtkcsslanguageserver.vala', 'gtkcsslanguageserver_aux.c']
c_args = ['-DG_LOG_DOMAIN="gtkcsslanguageserver"']
tgts += shared_module(
    'gtkcsslanguageserver',
    gtkcsslanguageserver_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)

