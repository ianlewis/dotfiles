HAS_CMAKE := $(shell which cmake)
HAS_CPP := $(shell which c++)
HAS_C := $(shell which cc)

install: install-bin install-vcprompt install-vim install-bash install-flake8 install-screen install-git install-virtualenvwrapper install-tmux

install-bin:
	mkdir -p ~/bin
	ln -sf `pwd`/bin/* ~/bin/

install-vcprompt:
ifdef HAS_C
	cd src/vcprompt && make && ln -fs `pwd`/vcprompt ~/bin/vcprompt
endif

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

install-flake8:
	rm -rf ~/.config/flake8
	mkdir -p ~/.config
	ln -s `pwd`/flake8/flake8.ini ~/.config/flake8

install-screen:
	rm -f ~/.screenrc
	ln -s `pwd`/screen/_screenrc ~/.screenrc

install-tmux:
	rm -f ~/.tmux.conf
	ln -s `pwd`/tmux/_tmux.conf ~/.tmux.conf

install-git:
	rm -f ~/.gitconfig
	ln -s `pwd`/git/_gitconfig ~/.gitconfig

install-virtualenvwrapper:
	mkdir -p ~/.virtualenvs
	ln -sf `pwd`/virtualenvwrapper/* ~/.virtualenvs/

install-mercurial:
	rm -f ~/.hgrc
	ln -s `pwd`/mercurial/_hgrc ~/.hgrc

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
