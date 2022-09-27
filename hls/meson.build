hls_sources = [
    'hls.vala',
    'hls_aux.c',
]
c_args = ['-DG_LOG_DOMAIN="hls"']
tgts += shared_module(
    'hls',
    hls_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
