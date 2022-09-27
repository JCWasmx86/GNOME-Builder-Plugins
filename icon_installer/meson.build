subdir('data')
icon_installer_sources = ['icon_installer.vala', icon_installer_resources]
c_args = ['-DG_LOG_DOMAIN="icon_installer"']
tgts += shared_module(
    'icon_installer',
    icon_installer_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
