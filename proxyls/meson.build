proxyls_sources = ['proxyls.vala', 'proxyls_aux.c']
c_args = ['-DG_LOG_DOMAIN="proxyls"']
tgts += shared_module(
    'proxyls',
    proxyls_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
