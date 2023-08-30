uname_s := $(shell uname -s)
$(info uname_s=$(uname_s))
uname_m := $(shell uname -m)
$(info uname_m=$(uname_m))

# system specific variables, add more here
BINDIR.Linux.x86_64 := bin/linux/amd64
BINDIR = $(BINDIR.$(uname_s).$(uname_m))

GOVERSION ?= 1.20.2
GOURL.Linux.x86_64 := https://go.dev/dl/go$(GOVERSION).linux-amd64.tar.gz
GOURL = $(GOURL.$(uname_s).$(uname_m))

NODEVERSION ?= 18.15.0
NODEURL.Linux.x86_64 := https://nodejs.org/dist/v${NODEVERSION}/node-v${NODEVERSION}-linux-x64.tar.xz
NODEURL = $(NODEURL.$(uname_s).$(uname_m))

SHELLCHECKURL.Linux.x86_64 := https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.linux.x86_64.tar.xz
SHELLCHECKURL = $(SHELLCHECKURL.$(uname_s).$(uname_m))

.PHONY: configure
configure: install-bin configure-vim configure-bash configure-flake8 configure-screen configure-git configure-virtualenvwrapper configure-tmux

.PHONY: install-bin
install-bin:
	mkdir -p ~/bin
	ln -sf `pwd`/bin/all/* ~/bin/
	ln -sf `pwd`/$(BINDIR)/* ~/bin/

.PHONY: configure-vim
configure-vim:
	rm -rf ~/.vim ~/.vimrc ~/.gvimrc ~/.vimrc.windows
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/_vimrc ~/.vimrc
	ln -s ~/.vim/_gvimrc ~/.gvimrc
	ln -s ~/.vim/_vimrc.windows ~/.vimrc.windows

.PHONY: configure-bash
configure-bash:
	rm -f ~/.inputrc ~/.profile ~/.bash_profile ~/.bashrc ~/.bash_aliases ~/.bash_aliases.kubectl ~/.bash_completion ~/.bash_logout ~/.dockerfunc ~/.ssh-find-agent
	ln -s `pwd`/bash/_inputrc ~/.inputrc
	ln -s `pwd`/bash/_profile ~/.profile
	ln -s `pwd`/bash/_bash_profile ~/.bash_profile
	ln -s `pwd`/bash/_bashrc ~/.bashrc
	ln -s `pwd`/bash/_bash_aliases ~/.bash_aliases
	ln -s `pwd`/bash/kubectl-aliases/.kubectl_aliases ~/.bash_aliases.kubectl
	ln -s `pwd`/bash/_bash_completion ~/.bash_completion
	ln -s `pwd`/bash/_bash_logout ~/.bash_logout
	ln -s `pwd`/bash/_dockerfunc ~/.dockerfunc
	ln -s `pwd`/bash/lib/ssh-find-agent/ssh-find-agent.sh ~/.ssh-find-agent

.PHONY: configure-flake8
configure-flake8:
	rm -rf ~/.config/flake8
	mkdir -p ~/.config
	ln -s `pwd`/flake8/flake8.ini ~/.config/flake8

.PHONY: configure-screen
configure-screen:
	rm -f ~/.screenrc
	ln -s `pwd`/screen/_screenrc ~/.screenrc

.PHONY: configure-tmux
configure-tmux:
	rm -f ~/.tmux.conf ~/.tmux/plugins
	ln -s `pwd`/tmux/_tmux.conf ~/.tmux.conf
	mkdir -p ~/.tmux
	ln -s `pwd`/tmux/plugins ~/.tmux/plugins

.PHONY: configure-git
configure-git:
	rm -f ~/.gitconfig
	ln -s `pwd`/git/_gitconfig ~/.gitconfig

.PHONY: configure-virtualenvwrapper
configure-virtualenvwrapper:
	mkdir -p ~/.virtualenvs
	ln -sf `pwd`/virtualenvwrapper/* ~/.virtualenvs/

.PHONY: configure-mercurial
configure-mercurial:
	rm -f ~/.hgrc
	ln -s `pwd`/mercurial/_hgrc ~/.hgrc

# Extra targets

.PHONY: install-opt
install-opt:
	mkdir -p ~/opt

.PHONY: install-go
install-go: install-opt
	wget -O /tmp/go.tar.gz $(GOURL)
	cd ~/opt && \
		rm -rf go && \
		tar xf /tmp/go.tar.gz && \
		mv go go-$(GOVERSION) && \
		ln -s go-$(GOVERSION) go

.PHONY: install-node
install-node: install-opt
	wget -O /tmp/node.tar.xz $(NODEURL)
	cd ~/opt && \
		tar xf /tmp/node.tar.xz && \
		ln -s node-v$(NODEVERSION)-linux-x64 node

.PHONY: install-editor-tools
install-editor-tools: install-flake8 install-black install-prettier install-js-beautify install-yamllint install-sql-formatter install-shellcheck install-shfmt

# Python virtualenv
$(HOME)/.local/share/venv:
	python3 -m venv $@

# For Python (linting)
.PHONY: install-flake8
install-flake8: $(HOME)/.local/share/venv
	$</bin/pip3 install flake8

# For Python (formatting)
.PHONY: install-black
install-black: $(HOME)/.local/share/venv
	$</bin/pip3 install black

# For Javascript, yaml, markdown (formatting)
.PHONY: install-prettier
install-prettier:
	npm install -g prettier

# For HTML, CSS, JSON (formatting)
.PHONY: install-js-beautify
install-js-beautify:
	npm install -g js-beautify

# For SQL (formatting)
.PHONY: install-sql-formatter
install-sqlparse:
	npm install -g sql-formatter

# For YAML (linting)
.PHONY: install-yamllint
install-yamllint: $(HOME)/.local/share/venv
	$</bin/pip3 install yamllint

# For shell (linting)
.PHONY: install-shellcheck
install-shellcheck:
	wget -O /tmp/shellcheck.tar.xz $(SHELLCHECKURL)
	cd ~/opt && tar xf /tmp/shellcheck.tar.xz

# For shell (formatting)
.PHONY: install-shfmt
install-shfmt:
	go install mvdan.cc/sh/v3/cmd/shfmt@latest

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

test:
	./test.sh

clean:
	rm -rf ycm_build
