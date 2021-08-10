HAS_C := $(shell which cc)

uname_s := $(shell uname -s)
$(info uname_s=$(uname_s))
uname_m := $(shell uname -m)
$(info uname_m=$(uname_m))

# system specific variables, add more here
BINDIR.Linux.x86_64 := bin/linux/amd64
BINDIR.Darwin.x86_64 := bin/macos/amd64
BINDIR = $(BINDIR.$(uname_s).$(uname_m))

GOURL.Linux.x86_64 := https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz
GOURL.Darwin.x86_64 := https://dl.google.com/go/go1.16.4.darwin-amd64.tar.gz
GOURL = $(GOURL.$(uname_s).$(uname_m))

NODEURL.Linux.x86_64 := https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz
NODEURL.Darwin.x86_64 := https://nodejs.org/dist/v14.17.0/node-v14.17.0-darwin-x64.tar.gz
NODEURL = $(NODEURL.$(uname_s).$(uname_m))

.PHONY: install
configure: install-bin install-vcprompt configure-vim configure-bash configure-flake8 configure-screen configure-git configure-virtualenvwrapper configure-tmux configure-remark

.PHONY: install-bin
install-bin:
	mkdir -p ~/bin
	ln -sf `pwd`/bin/all/* ~/bin/
	ln -sf `pwd`/$(BINDIR)/* ~/bin/

.PHONY: install-vcprompt
install-vcprompt:
ifdef HAS_C
	cd src/vcprompt && make && ln -fs `pwd`/vcprompt ~/bin/vcprompt
endif

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
	rm -f ~/.tmux.conf
	ln -s `pwd`/tmux/_tmux.conf ~/.tmux.conf

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

.PHONY: configure-remark
configure-remark:
	rm -f ~/.remarkrc
	ln -s `pwd`/remark/_remarkrc ~/.remarkrc

# Extra targets

.PHONY: install-opt
install-opt:
	mkdir -p ~/opt

.PHONY: install-go
install-go: install-opt
	wget -O /tmp/go.tar.gz $(GOURL)
	cd ~/opt && rm -rf go/ && tar xf /tmp/go.tar.gz

.PHONY: install-node
install-node: install-opt
	wget -O /tmp/node.tar.gz $(NODEURL)
	cd ~/opt && tar xf /tmp/node.tar.gz

.PHONY: install-editor-tools
install-editor-tools: install-flake8 install-black install-remark install-prettier install-standard install-js-beautify

.PHONY: install-flake8
install-flake8:
	pip3 install --user flake8

.PHONY: install-black
install-black:
	pip3 install --user black

.PHONY: install-remark
install-remark:
	npm install -g remark-cli remark-frontmatter

.PHONY: install-prettier
install-prettier:
	npm install -g prettier

# For Javascript
.PHONY: install-standard
install-standard:
	npm install -g standard

# For HTML, CSS, JSON
.PHONY: install-js-beautify
install-js-beautify:
	npm install -g js-beautify

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

test:
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/mnt:ro \
		-w /mnt \
		--entrypoint ./test.sh \
		gcr.io/ianlewis-dockerfiles/shellcheck

clean:
	rm -rf ycm_build
