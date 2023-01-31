mesonlsp_sources = [
    'meson.vala',
    'meson_aux.c',
]
c_args = ['-DG_LOG_DOMAIN="mesonlsp"']
tgts += shared_module(
    'mesonlsp',
    mesonlsp_sources,
    c_args: c_args,
    dependencies: dependencies,
    include_directories: inc,
    install: true,
    install_dir: install_dir,
    vala_args: get_option('use_swift_meson_lsp') ? '--define=LS_NAME=1' : '--define=FOO',
)
