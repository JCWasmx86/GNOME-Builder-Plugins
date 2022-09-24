stack_sources = [
	'stack.vala'
]
c_args = ['-DG_LOG_DOMAIN="stack"']
tgts += shared_module('stack',
              stack_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
