swift_sources = [
	'swift.vala'
]
c_args = ['-DG_LOG_DOMAIN="swift"']
tgts += shared_module('swift',
              swift_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
