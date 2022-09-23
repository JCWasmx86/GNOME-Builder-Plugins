swift_lint_sources = [
]
c_args = ['-DG_LOG_DOMAIN="swift-lint"']
shared_module('swift-lint',
              swift_lint_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
