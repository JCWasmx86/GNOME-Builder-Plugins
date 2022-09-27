muon_sources = ['muon.vala']
c_args = ['-DG_LOG_DOMAIN="muon"']
tgts += shared_module(
    'muon',
    muon_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
