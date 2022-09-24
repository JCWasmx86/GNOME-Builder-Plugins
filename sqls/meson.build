sqls_sources = [
	'sqls.vala',
	'sqls_aux.c',
]
c_args = ['-DG_LOG_DOMAIN="sqls"']
tgts += shared_module('sqls',
              sqls_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
