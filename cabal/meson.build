cabal_sources = [
	'cabal.vala',
]
c_args = ['-DG_LOG_DOMAIN="cabal"']
tgts += shared_module('cabal',
              cabal_sources,
              c_args : c_args,
              dependencies : dependencies,
              include_directories : inc,
              install: true,
              install_dir: install_dir)
