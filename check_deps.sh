#!/usr/bin/env bash
sh -l -c "which --help" 2>/dev/null >/dev/null || echo "Command 'which' is missing"
sh -l -c "tput -V" 2>/dev/null >/dev/null || echo "Command 'tput' is missing"
enabled_plugins=("icon_installer" "sqlconnections" "xmlfmt")
disabled_plugins=()
packages_to_install_dnf=()
paths_to_add_to_profile=()
ghcup_to_install=()
go_to_install=()
cargo_to_install=()
manually_install=()

check_file() {
	if test -f "$1"; then
		echo "$1"... "$(tput bold)$(tput setaf 2)Exists$(tput sgr0)"
		return 0
	else
		echo "$1"... "$(tput bold)$(tput setaf 1)Does not exist$(tput sgr0)"
		return 1
	fi
}
check_command() {
	if sh -l -c "which $1" >/dev/null 2>&1; then
		echo "$1"... "$(tput bold)$(tput setaf 2)Was found$(tput sgr0)"
		return 0
	else
		echo "$1"... "$(tput bold)$(tput setaf 1)Not found$(tput sgr0)"
		return 1
	fi
}
check_plugin() {
	if check_command "$1"; then
		echo "$(tput bold)$(tput setaf 2)$2 can be enabled$(tput sgr0)"
		enabled_plugins+=("$2")
	else
		echo "$(tput bold)$(tput setaf 1)$2 won't work$(tput sgr0)"
		disabled_plugins+=("$2")
	fi
}
is_disabled() {
	if [[ " ${disabled_plugins[*]} " == *" $1 "* ]]; then
		return 0
	else
		return 1
	fi
}

check_plugin_ex() {
	if check_file "$1" && check_command "$2"; then
		echo "$(tput bold)$(tput setaf 2)$3 can be enabled$(tput sgr0)"
		enabled_plugins+=("$3")
	else
		echo "$(tput bold)$(tput setaf 1)$3 won't work$(tput sgr0)"
		disabled_plugins+=("$3")
	fi
}
# icon_installer,sqlconnections,xmlfmt will always work
export PATH=/usr/bin/:/bin:/usr/local/bin
check_plugin_ex ~/.ghcup/bin/cabal cabal "cabal"
check_plugin clangd "clangd"
check_plugin hadolint "hadolint"
check_plugin_ex ~/.ghcup/bin/haskell-language-server-wrapper1 haskell-language-server-wrapper1 "hls"
check_plugin meson_lsp "meson"
check_plugin pylint "pylint"
check_plugin shellcheck "shellcheck"
check_plugin shfmt "shfmt"
check_plugin sourcekit-lsp "sourcekit"
check_plugin swift-format "swift-format"
check_plugin swiftlint "swift-lint"
check_plugin sqls "sqls"
check_plugin_ex ~/.ghcup/bin/stack stack "stack"
check_plugin texlab "texlab"
echo "Enabled: ${enabled_plugins[*]}"
if ((${#disabled_plugins[@]} == 0)); then
	exit 0
fi
echo "Disabled: ${disabled_plugins[*]}"
if is_disabled "cabal"; then
	if test -f ~/.ghcup/bin/cabal; then
		paths_to_add_to_profile=(~/.ghcup/bin)
	else
		ghcup_to_install+=("cabal")
	fi
fi
if is_disabled "clangd"; then
	packages_to_install_dnf+=("clang-tools-extra")
fi
if is_disabled "hls"; then
	if test -f ~/.ghcup/bin/haskell-language-server-wrapper; then
		paths_to_add_to_profile=(~/.ghcup/bin)
	else
		ghcup_to_install+=("haskell-language-server")
	fi
fi
if is_disabled "hadolint"; then
	packages_to_install_dnf+=("hadolint")
fi
if is_disabled "meson"; then
	manually_install+=("mesonlsp")
fi
if is_disabled "swift-format"; then
	manually_install+=("swift-format")
fi
if is_disabled "swift-lint"; then
	manually_install+=("swiftlint")
fi
if is_disabled "pylint"; then
	packages_to_install_dnf+=("pylint")
fi
if is_disabled "shellcheck"; then
	packages_to_install_dnf+=("ShellCheck")
fi
if is_disabled "shfmt"; then
	packages_to_install_dnf+=("shfmt")
fi
if is_disabled "sourcekit"; then
	packages_to_install_dnf+=("swift-lang")
fi
if is_disabled "sqls"; then
	if test -f ~/go/bin/sqls; then
		paths_to_add_to_profile=(~/go/bin)
	else
		go_to_install+=("github.com/lighttiger2505/sqls@latest")
	fi
fi
if is_disabled "swift"; then
	packages_to_install_dnf+=("swift-lang")
fi
if is_disabled "stack"; then
	if test -f ~/.ghcup/bin/stack; then
		paths_to_add_to_profile=(~/.ghcup/bin)
	else
		ghcup_to_install+=("stack")
	fi
fi
if is_disabled "texlab"; then
	if test -f ~/.cargo/bin/texlab; then
		paths_to_add_to_profile+=(~/.cargo/bin)
	else
		cargo_to_install+=("texlab")
	fi
fi
if ((${#packages_to_install_dnf[@]} != 0)); then
	echo "Install these dnf packages: $(tput bold)$(tput setaf 6)${packages_to_install_dnf[*]}$(tput sgr0)"
fi
if ((${#paths_to_add_to_profile[@]} != 0)); then
	echo "Add these paths to ~/.profile: $(tput bold)$(tput setaf 6)${paths_to_add_to_profile[*]}$(tput sgr0)"
fi
if ((${#ghcup_to_install[@]} != 0)); then
	echo "Install these packages using ghcup: $(tput bold)$(tput setaf 6)${ghcup_to_install[*]}$(tput sgr0)"
fi
if ((${#go_to_install[@]} != 0)); then
	echo "Install these packages using go: $(tput bold)$(tput setaf 6)${go_to_install[*]}$(tput sgr0)"
fi
if ((${#cargo_to_install[@]} != 0)); then
	echo "Install these packages using cargo: $(tput bold)$(tput setaf 6)${cargo_to_install[*]}$(tput sgr0)"
fi
if ((${#manually_install[@]} != 0)); then
	echo "Install these packages manually: $(tput bold)$(tput setaf 6)${manually_install[*]}$(tput sgr0)"
fi
