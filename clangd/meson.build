clangd_sources = ['clangd.vala', 'clangd_aux.c']
c_args = ['-DG_LOG_DOMAIN="clangd"']
tgts += shared_module(
    'clangd_gb',
    clangd_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
