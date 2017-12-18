HAS_CMAKE := $(shell which cmake)
HAS_CPP := $(shell which c++)
HAS_C := $(shell which cc)

install: install-bin install-vcprompt install-vim install-bash install-screen install-git install-virtualenvwrapper

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
	rm -f ~/.inputrc ~/.profile ~/.bashrc ~/.bash_aliases ~/.bash_completion ~/.bash_logout ~/.dockerfunc
	ln -s `pwd`/bash/_inputrc ~/.inputrc
	ln -s `pwd`/bash/_profile ~/.profile
	ln -s `pwd`/bash/_bashrc ~/.bashrc
	ln -s `pwd`/bash/_bash_aliases ~/.bash_aliases
	ln -s `pwd`/bash/_bash_completion ~/.bash_completion
	ln -s `pwd`/bash/_bash_logout ~/.bash_logout
	ln -s `pwd`/bash/_dockerfunc ~/.dockerfunc

install-screen:
	rm -f ~/.screenrc
	ln -s `pwd`/screen/_screenrc ~/.screenrc

install-git:
	rm -f ~/.gitconfig
	ln -s `pwd`/git/_gitconfig ~/.gitconfig

install-virtualenvwrapper:
	mkdir -p ~/.virtualenvs
	ln -sf `pwd`/virtualenvwrapper/* ~/.virtualenvs/

install-mercurial:
	rm -f ~/.hgrc
	ln -s `pwd`/mercurial/_hgrc ~/.hgrc

clean:
	rm -rf ycm_build
