## Cabal
- Install using [GHCup](https://www.haskell.org/ghcup/)
- `/home/user/.ghcup/bin/cabal` must exist
## Clangd
- Install [Clangd](https://clangd.llvm.org/) using your distro's package manager
- `/usr/bin/clangd` must exist (Other paths may work, too)
## HLS
- Install [Haskell Language Server](https://haskell-language-server.readthedocs.io/en/latest/index.html) using [GHCup](https://www.haskell.org/ghcup/)
- `/home/user/.ghcup/bin/haskell-language-server-wrapper` must exist
- Create a file `/home/user/.ghcup/bin/haskell-language-server-wrapper1` with these contents:
```sh
#!/usr/bin/env bash
export PATH=$PATH:$HOME/.ghcup/bin:$HOME/.cabal/bin
if (( $# != 0 )); then
        haskell-language-server-wrapper $*
else
        haskell-language-server-wrapper --lsp --debug
fi
```
## Meson
- Install [MesonLSP](https://github.com/jcwasmx86/mesonlsp), it is work-in-progress!
## Pylint
- Install pylint using your distro's package manager
- `/usr/bin/pylint` must exist (Other paths may work, too)
## Shellcheck
- Install shellcheck using your distro's package manager
- `/usr/bin/shellcheck` must exist (Other paths may work, too)
## Shfmt
- Install shfmt using your distro's package manager
- `/usr/bin/shfmt` must exist (Other paths may work, too)
## Sqls
- Install [sqls](https://github.com/lighttiger2505/sqls)
- `sqls` must be on the path
## Stack
- Install using [GHCup](https://www.haskell.org/ghcup/)
- `/home/user/.ghcup/bin/stack` must exist
## Texlab
- Install [texlab](https://github.com/latex-lsp/texlab)
- Copy it to `/usr/bin/`, so you have the file `/usr/bin/texlab`