shfmt_sources = [
	'shfmt.vala'
]
c_args = ['-DG_LOG_DOMAIN="shfmt"']
tgts += shared_module('shfmt',
              shfmt_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
