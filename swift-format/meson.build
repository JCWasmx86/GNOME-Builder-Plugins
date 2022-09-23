swift_format_sources = [
	'swift-format.vala'
]
c_args = ['-DG_LOG_DOMAIN="swift-format"']
shared_module('swift-format',
              swift_format_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
