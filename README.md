# GNOME-Builder plugins

These are all plugins I use(d). They are only compatible with GNOME-Builder Nightly. Maybe they work with older versions, but this is not
guaranteed.


## Install
### Without docker
```
# If you have Fedora 37
sudo dnf install git vala meson gcc libgee-devel json-glib-devel gtk4-devel gtksourceview5-devel libadwaita-devel libpeas-devel template-glib-devel g++ libsoup3-devel
# or if you have Ubuntu 22.10 (Tested: That it compiles)
sudo apt install git valac meson gcc libgee-0.8-dev libjson-glib-dev libgtk-4-dev libgtksourceview-5-dev libadwaita-1-dev libpeas-dev libtemplate-glib-1.0-dev g++ libsoup-3.0-dev zip
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
| Name            | Description    | Will attempt to upstream? |
|-----------------|:--------------:|:-----------------------------------------------------------------------------------------------------------------:|
| cabal           | Integration for the cabal buildsystem                                                                                         | ✅ |
| clangd          | (Copied from upstream, converted to Vala): Clangd integration                                                                 | ❌ |
| gitgui          | A small git integration                                                                                                       | ❌ |
| hadolint        | Integration for Hadolint, the Dockerfile linter                                                                               | ✅ |
| hls             | Integration for the Haskell Language Server                                                                                   | ✅ |
| icon_installer  | Allow installing icons easily in your project                                                                                 |    |
| markdown        | Indenter for Markdown                                                                                                         |    |
| meson           | Integration for my meson language server                                                                                      | ❌ |
| muon            | Format `meson.build` files using muon                                                                                         | ✅ |
| pylint          | Integration with Pylint                                                                                                       | ✅ |
| shfmt           | Shfmt integration                                                                                                             | ❌ |
| sourcekit       | Integration for Sourcekit, the Swift language server                                                                          | ✅ |
| sqls            | Integration for the SQL language server                                                                                       | ✅ |
| stack           | Integration for the stack buildsystem                                                                                         | ✅ |
| swift           | Integration for the swift buildsystem                                                                                         | ✅ |
| swift-format    | Integration for swift-formatter                                                                                               | ✅ |
| swift-templates | Extends the CreateProject-Dialog to add Swift-Support                                                                         | ✅ |
| swift-lint      | Integration for swift-lint                                                                                                    | ✅ |
| texlab          | LaTeX integration (Disabled by default, enable by using `-Dplugin_texlab=enabled`)                                            | ❌ |
| xmlfmt          | Formatter for XML                                                                                                             | ✅ |

- ✅: Yes
- ❌: No
- Empty: Time will tell

## Changes to ide.vapi
- `HtmlGenerator.for_buffer`: Remove public
- Ide.BuildSystem:
	- `get_build_flags_async`: virtual
	- `get_build_flags_for_files_async`: virtual
	- `get_project_version`: virtual
	- `get_srcdir`: virtual
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

## Updating libraries
- Update vapis
- Update headers
- Test that it compiles and works
