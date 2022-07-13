plugins = [
	'shellcheck.plugin',
	'shfmt.plugin',
	'cabal.plugin',
	'stack.plugin',
	'mesonlsp.plugin',
	'clangd.plugin',
	'hls.plugin',
	'icon_installer.plugin'
]
config = configuration_data()
config.set('BUILDER_ABI', get_option('builder_abi'))
foreach e : plugins
	configure_file(input: e, output: e, configuration: config)
endforeach