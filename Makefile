HAS_CMAKE := $(shell which cmake)

install: install-bin install-vim install-bash install-screen install-git install-virtualenvwrapper

install-bin:
	mkdir -p ~/bin
	ln -sf `pwd`/bin/* ~/bin/

install-vim:
ifdef HAS_CMAKE
	mkdir -p ycm_build
	cd ycm_build; cmake -G "Unix Makefiles" . ../vim/bundle/YouCompleteMe/third_party/ycmd/cpp
	cd ycm_build; make ycm_support_libs
endif
	rm -rf ~/.vim ~/.vimrc ~/.gvimrc ~/.vimrc.windows
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/_vimrc ~/.vimrc
	ln -s ~/.vim/_gvimrc ~/.gvimrc
	ln -s ~/.vim/_vimrc.windows ~/.vimrc.windows

install-bash:
	rm -f ~/.inputrc ~/.profile ~/.bashrc ~/.bash_aliases ~/.bash_completion ~/.bash_logout
	ln -s `pwd`/bash/_inputrc ~/.inputrc
	ln -s `pwd`/bash/_profile ~/.profile
	ln -s `pwd`/bash/_bashrc ~/.bashrc
	ln -s `pwd`/bash/_bash_aliases ~/.bash_aliases
	ln -s `pwd`/bash/_bash_completion ~/.bash_completion
	ln -s `pwd`/bash/_bash_logout ~/.bash_logout

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
