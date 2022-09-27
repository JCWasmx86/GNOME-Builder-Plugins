sqlconnections_sources = [
    'sqlconnections.vala',
]
c_args = ['-DG_LOG_DOMAIN="sqlconnections"']
tgts += shared_module(
    'sqlconnections',
    sqlconnections_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
