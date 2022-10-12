sourcekit_sources = [
    'sourcekit.vala',
    'sourcekit_aux.c',
]
c_args = ['-DG_LOG_DOMAIN="sourcekit"']
tgts += shared_module(
    'sourcekit',
    sourcekit_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
