#!/usr/bin/env bash
enabled_plugins=("icon_installer" "sqlconnections" "xmlfmt")
disabled_plugins=()

check_file() {
	if test -f $1; then
		echo $1... $(tput bold)$(tput setaf 2)Exists$(tput sgr0)
		return 0
	else
		echo $1... $(tput bold)$(tput setaf 1)Does not exist$(tput sgr0)
		return 1
	fi
}
check_command() {
	if sh -l -c "which $1" >/dev/null 2>&1; then
		echo $1... $(tput bold)$(tput setaf 2)Was found$(tput sgr0)
		return 0
	else
		echo $1... $(tput bold)$(tput setaf 1)Not found$(tput sgr0)
		return 1
	fi
}
check_plugin() {
	if check_command $1; then
		echo $(tput bold)$(tput setaf 2)$2 can be enabled$(tput sgr0)
		enabled_plugins+=("$2")
	else
		echo $(tput bold)$(tput setaf 1)$2 won\'t work$(tput sgr0)
		disabled_plugins+=("$2")
	fi
}
check_plugin_ex() {
	if check_file $1 && check_command $2; then
		echo $(tput bold)$(tput setaf 2)$3 can be enabled$(tput sgr0)
		enabled_plugins+=("$3")
	else
		echo $(tput bold)$(tput setaf 1)$3 won\'t work$(tput sgr0)
		disabled_plugins+=("$3")
	fi
}
# icon_installer,sqlconnections,xmlfmt will always work
export PATH=/usr/bin/:/bin
check_plugin_ex ~/.ghcup/bin/cabal cabal "cabal"
check_plugin clangd "clangd"
check_plugin_ex ~/.ghcup/bin/haskell-language-server-wrapper1 haskell-language-server-wrapper1 "hls"
check_plugin meson_lsp "meson"
check_plugin pylint "pylint"
check_plugin shellcheck "shellcheck"
check_plugin shfmt "shfmt"
check_plugin sourcekit-lsp "sourcekit"
check_plugin sqls "sqls"
check_plugin_ex ~/.ghcup/bin/stack stack "stack"
check_plugin texlab "texlab"
echo "Enabled: ${enabled_plugins[@]}"
echo "Disabled: ${disabled_plugins[@]}"