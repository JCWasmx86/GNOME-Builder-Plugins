# GNOME-Builder plugins

These are all plugins I use(d). They are only compatible with GNOME-Builder Nightly. Maybe they work with older versions, but this is not
guaranteed.


## Install

### Fedora 36
*It is advised to run this in e.g. a docker container or a VM, as this makes destructive changes
by updating libadwaita without package manager.*
```
sudo dnf install git vala meson gcc libgee-devel json-glib-devel gtk4-devel gtksourceview5-devel libadwaita-devel libpeas-devel template-glib-devel g++
git clone https://gitlab.gnome.org/GNOME/libadwaita
cd libadwaita
meson build -Dprefix=/usr
cd build
sudo ninja install
cd ../..
git clone https://github.com/JCWasmx86/GNOME-Builder-Plugins
cd GNOME-Builder-Plugins
meson build
cd build
ninja install
```
### Docker/Podman
```
DOCKER_BUILDKIT=1 podman build --file Dockerfile --output out --no-cache .
```
After that, a file called `dist.zip` will be in the `out` directory.
You can copy it to `~/.local/share/gnome-builder/plugins/` (Create it if it
does not exist) and unzip it there.
```
mkdir -p ~/.local/share/gnome-builder/plugins
cp out/dist.zip ~/.local/share/gnome-builder/plugins
cd ~/.local/share/gnome-builder/plugins
unzip dist.zip
```

## Plugins
- cabal: Integration for the cabal buildsystem
- clangd: (Copied from upstream, converted to Vala): Clangd integration
- hadolint: Integration for Hadolint, the Dockerfile linter
- hls: Integration for the Haskell Language Server
- icon_installer: Allow installing icons easily in your project
- markdown: Indenter/SymbolResolver for Markdown
- meson: Integration for my meson language server
- muon: Format `meson.build` files using muon
- pylint: Integration with Pylint
- shfmt: Shfmt integration
- sourcekit: Integration for Sourcekit, the Swift language server
- sqlconnections: Allows you to create the config for sqls using a GUI (Disabled by default, enable by using `-Dplugin_sqlconnections=enabled`)
- sqls: Integration for the SQL language server
- stack: Integration for the stack buildsystem
- swift: Integration for the swift buildsystem
- swift-format: Integration for swift-formatter
- swift-tempaltes: Extends the CreateProject-Dialog to add Swift-Support
- swift-lint: Integration for swift-lint
- texlab: LaTeX integration (Disabled by default, enable by using `-Dplugin_texlab=enabled`)
- xmlfmt: Formatter for XML

## Changes to ide.vapi
- `HtmlGenerator.for_buffer`: Remove public
- Ide.BuildSystem:
	- `get_build_flags_async`: virtual
	- `get_build_flags_for_files_async`: virtual
	- `get_project_version`: virtual
	- `supports_language`: virtual
	- `supports_toolchain`: virtual
- Ide.WorkspaceAddin:
	- `ref_action_group`: virtual
	- `restore_session`: virtual
	- `restore_session_item`: virtual
	- `save_session`: virtual
- Ide.RunCommand:
	- `set_argv`: string array as arguments
	- `set_argv`: `[CCode (array_length = false, array_null_terminated = true)]` to the argument
- Ide.RunContext:
	- `append_args`: string array as arguments
	- `append_args`: `[CCode (array_length = false, array_null_terminated = true)]` to the argument
- All: `s/Tmpl/Template/g`
- Copy `ide-shortcut-info.h` to `libide/gui`

## Updating libraries
- Update vapis
- Update headers
- Test that it compiles and works
