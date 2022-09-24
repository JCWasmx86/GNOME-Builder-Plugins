xmlfmt_sources = [
	'xmlfmt.vala'
]
c_args = ['-DG_LOG_DOMAIN="xmlfmt"']
tgts += shared_module('xmlfmt',
              xmlfmt_sources,
              c_args : c_args,
              dependencies : dependencies + dependency('libxml-2.0'),
              include_directories : inc,
              install: true,
              install_dir: install_dir)
