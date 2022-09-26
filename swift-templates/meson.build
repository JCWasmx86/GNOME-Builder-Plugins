swift_template_sources = [
	'swift-templates.vala'
]
c_args = ['-DG_LOG_DOMAIN="swift-templates"']
tgts += shared_module('swift-templates',
              swift_template_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
