swift_lint_sources = ['swift-lint.vala']
c_args = ['-DG_LOG_DOMAIN="swift-lint"']
tgts += shared_module(
    'swift-lint',
    swift_lint_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
)
