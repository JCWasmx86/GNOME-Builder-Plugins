pyright_sources = ['pyright.vala', 'pyright_aux.c']
c_args = ['-DG_LOG_DOMAIN="pyright"']
tgts += shared_module(
    'pyright',
    pyright_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
