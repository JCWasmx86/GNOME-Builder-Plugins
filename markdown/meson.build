markdown_sources = ['markdown.vala']
c_args = ['-DG_LOG_DOMAIN="markdown"']
tgts += shared_module(
    'markdown',
    markdown_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
