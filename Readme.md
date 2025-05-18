NOTE:  This is not meant to be a daily driver.   Just for taking a glance at the awesome nyoom config

Tested with Podman on Fedora; Should work with podman on any distro and probably Docker....

1)  Run ./enter to enter container (Will first build and clone nyoom as submodule)
2)  ./start.sh  will install nyoom as of 2022-12-15 you can add another date as parameter.
3)  Run nvim

I have not been able to get anything more recent to start.  There are issues with both packer an hotpot.
However there are also now multiple issues with plugins that are no longer compatible.

. nvim-notify and lspconfig: update to neovim 10/f40 solves this
. tree-sitter:  using version with same checkout date as nyoom/packer/hotpot, but probably not compatible with neovim 10
. much more, but it does start up....
