HAS_CMAKE := $(shell which cmake)
HAS_CPP := $(shell which c++)
HAS_C := $(shell which cc)

uname_s := $(shell uname -s)
$(info uname_s=$(uname_s))
uname_m := $(shell uname -m)
$(info uname_m=$(uname_m))

# system specific variables, add more here
BINDIR.Linux.x86_64 := bin/linux/amd64
BINDIR.Darwin.x86_64 := bin/macos/amd64
BINDIR = $(BINDIR.$(uname_s).$(uname_m))

GOURL.Linux.x86_64 := https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz
GOURL.Darwin.x86_64 := https://dl.google.com/go/go1.12.5.darwin-amd64.tar.gz
GOURL = $(GOURL.$(uname_s).$(uname_m))


NODEURL.Linux.x86_64 := https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-x64.tar.xz
NODEURL.Darwin.x86_64 := https://nodejs.org/dist/v10.15.3/node-v10.15.3-darwin-x64.tar.gz
NODEURL = $(NODEURL.$(uname_s).$(uname_m))

.PHONY: install
install: install-bin install-vcprompt install-vim install-bash install-flake8 install-screen install-git install-virtualenvwrapper install-tmux

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

.PHONY: install-vim
install-vim:
ifdef HAS_CMAKE
ifdef HAS_CPP
ifdef HAS_C
	cd vim/bundle/YouCompleteMe && ./install.sh --clang-completer --gocode-completer
endif
endif
endif
	rm -rf ~/.vim ~/.vimrc ~/.gvimrc ~/.vimrc.windows
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/_vimrc ~/.vimrc
	ln -s ~/.vim/_gvimrc ~/.gvimrc
	ln -s ~/.vim/_vimrc.windows ~/.vimrc.windows

.PHONY: install-bash
install-bash:
	rm -f ~/.inputrc ~/.profile ~/.bashrc ~/.bash_aliases ~/.bash_completion ~/.bash_logout ~/.dockerfunc ~/.ssh-find-agent
	ln -s `pwd`/bash/lib/ssh-find-agent/ssh-find-agent.sh ~/.ssh-find-agent
	ln -s `pwd`/bash/_inputrc ~/.inputrc
	ln -s `pwd`/bash/_profile ~/.profile
	ln -s `pwd`/bash/_bashrc ~/.bashrc
	ln -s `pwd`/bash/_bash_aliases ~/.bash_aliases
	ln -s `pwd`/bash/_bash_completion ~/.bash_completion
	ln -s `pwd`/bash/_bash_logout ~/.bash_logout
	ln -s `pwd`/bash/_dockerfunc ~/.dockerfunc

.PHONY: install-flake8
install-flake8:
	rm -rf ~/.config/flake8
	mkdir -p ~/.config
	ln -s `pwd`/flake8/flake8.ini ~/.config/flake8

.PHONY: install-screen
install-screen:
	rm -f ~/.screenrc
	ln -s `pwd`/screen/_screenrc ~/.screenrc

.PHONY: install-tmux
install-tmux:
	rm -f ~/.tmux.conf
	ln -s `pwd`/tmux/_tmux.conf ~/.tmux.conf

.PHONY: install-git
install-git:
	rm -f ~/.gitconfig
	ln -s `pwd`/git/_gitconfig ~/.gitconfig

.PHONY: install-virtualenvwrapper
install-virtualenvwrapper:
	mkdir -p ~/.virtualenvs
	ln -sf `pwd`/virtualenvwrapper/* ~/.virtualenvs/

.PHONY: install-mercurial
install-mercurial:
	rm -f ~/.hgrc
	ln -s `pwd`/mercurial/_hgrc ~/.hgrc

# Extra targets

.PHONY: install-opt
install-opt:
	mkdir -p ~/opt

.PHONY: install-go
install-go: install-opt
	wget -O /tmp/go.tar.gz $(GOURL)
	cd ~/opt && tar xf /tmp/go.tar.gz

.PHONY: install-node
install-node: install-opt
	wget -O /tmp/node.tar.gz $(NODEURL)
	cd ~/opt && tar xf /tmp/node.tar.gz

.PHONY: install-flake8
install-flake8:
	pip3 install --user flake8

.PHONY: install-black
install-black:
	pip3 install --user black

.PHONY: install-remark
install-remark: install-node
	npm install -g remark-cli

# For HTML, Javascript, CSS, JSON
.PHONY: install-js-beautify
install-js-beautify: install-node
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
