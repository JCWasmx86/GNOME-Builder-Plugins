# GNOME-Builder plugins

These are all plugins I use(d). They are only compatible with GNOME-Builder Nightly. Maybe they work with older versions, but this is not
guaranteed.

## Plugins
- cabal: Integration for the cabal buildsystem
- clangd: (Copied from upstream, converted to Vala): Clangd integration
- hls: Integration for the Haskell Language Server
- icon_installer: Allow installing icons easily in your project
- jdtls: Integration for the Eclipse Java Language Server (TODO)
- meson: Integration for my meson language server
- pylint: Integration with Pylint
- shellcheck: Shellcheck integration
- shfmt: Shfmt integration
- stack: Integration for the stack buildsystem
- texlab: LaTeX integration
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
- Ide.RunCommand:
	- `set_argv`: string array as arguments
	- `set_argv`: `[CCode (array_length = false, array_null_terminated = true)]` to the argument

## Updating libraries
- Update vapis
- Update headers
- Add ide-application-tweaks.h to include/libide/gui
- Test that it compiles and works