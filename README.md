Ian's dotfiles
=====================

These dotfiles are based on [Armin Ronacher's dotfiles](https://github.com/mitsuhiko/dotfiles)
where the idea was copied shamelessly.

# Install

Dotfiles are installed using a simple Makefile in the root directory. Just run
make to install the files.

# vcprompt

There is a copy of the vcprompt program in the src directory. Build it by
running make in the vcprompt directory and installing in to your user's bin
directory.

    $ cd src/vcprompt
    $ make
    ...
    $ mkdir -p ~/bin && cp vcprompt ~/bin 

# Compatibility

The scripts here should work on MacOS and Linux. I have tested them on Ubuntu
14.04 LTS and Mac OS X Yosemite. They will probably work on other setups as
well but YMMV. If you find anything not working feel free to open up an issue
to let me know.
