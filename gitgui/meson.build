gitgui_sources = ['gitgui.vala']
c_args = ['-DG_LOG_DOMAIN="gitgui"']
tgts += shared_module(
    'gitgui',
    gitgui_sources,
    c_args: c_args,
    dependencies: dependencies + dependency('libxml-2.0'),
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
