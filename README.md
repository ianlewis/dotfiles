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

I really don't use Mac OS much so these dotfiles aren't tested there. I try to
make them as compatible as possible but things are just not likely to work
properly and even if they did you're likely to find these dotfiles lacking
convienent settings for Mac OS.
