pylint_sources = [
	'pylint.vala'
]
c_args = ['-DG_LOG_DOMAIN="pylint"']
shared_module('pylint',
              pylint_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
