texlab_sources = [
	'texlab.vala',
	'texlab_aux.c'
]
c_args = ['-DG_LOG_DOMAIN="texlab"']
shared_module('texlab',
              texlab_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
