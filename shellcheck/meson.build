shellcheck_sources = [
	'shellcheck.vala'
]
c_args = ['-DG_LOG_DOMAIN="shellcheck"']
shared_module('shellcheck',
              shellcheck_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
