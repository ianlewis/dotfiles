# Bash configuration

This directory contains bash specific resource configuration, libraries, and
scripts.

## features

- [`sbp`] prompt in tokyo night color scheme with
  git, python virtualenv, and nix shell integration.
- cli syntax highlighting and auto-suggestions with [`ble.sh`].
- [bash completion](./_bash_completion) for `pip`, `kubectl`, and `aqua` in
  addition to the system default completions.
- [bash aliases](./_bash_aliases) for common commands, including
  [`kubectl-aliases`].
- `ssh-agent` integration to find the running ssh-agent and set the
  `ssh_auth_sock` environment variable.
- `tmux` integration to set the terminal title and display the current working
  directory in the status bar. tmux session reuse is enabled by default.
- integration with google cloud sdk, including `gcloud`, `gsutil`, and `bq`
  commands installed in `~/opt/google-cloud-sdk`.

## bash resource configuration (`rc`)

resource configuration for different purposes are broken into separate files
using their standard names, such as `.bash_aliases` and `.bash_completion`.

machine local files can be created by suffixing `.local` to the filename and
putting it in your home directory. for example, `.bashrc` will load a script
called `.bashrc.local` if it exists. this goes for other scripts like
`.bash_aliases`, `.bash_completion`, etc.

each resource configuration file is wrapped in a function that is called at the
end of the file. this allows for setting local variables that don't corrupt the
terminal session.

`.inputrc` contains shell key mappings.

## custom scripts

- [`clone`](../bin/all/clone.bash): A script to easily clone a repository from
  GitHub to a local directory that defaults to `~/src/<owner>/<repo>`.
- [`ts`](../bin/all/ts.bash): A timestamp utility that adds timestamps to log
  output that is piped to standard input.
- [`tmux-sessionizer`](../bin/all/tmux-sessionizer.bash) (alias: `ns`): This
  script to easily create and manage tmux sessions for a "project" folder. It is
  aliased to `ns` and defaults to searching directories in `~/src`.
- `tw`: an alias to `tmux-sessionizer` that creates a new tmux session for a
  new temporary directory in the `~/.tmp` directory. This is useful for creating
  testing environments that will be cleaned up automatically.
- [`project-windowizer`](../bin/all/project-windowizer.bash) (alias: `pw`): This
  script splits a tmux window vertically and runs a command in the right pane.
  It defaults to running `nvim` in the right pane for development.
- [`randstr`](../bin/all/randstr.bash): A script to generate a random string of
  a given length. Strings are generated using `/dev/urandom` so they are
  suitable for use as passwords or other secure tokens.
- [`withpass`](../bin/all/withpass.bash): A script to run a command with a
  password provided via standard input and passing it to a command via an
  environment variable. This is useful for keeping secrets out of the command
  line history and process list without exporting them in the environment.

## Bash libraries

The `lib` directory contains bash libraries that are used in resource
configuration etc.

- [`sbp`]: A simple bash prompt library that provides a simple way to customize
  the bash prompt. It is used in `.bashrc` to set the prompt. A local
  `.sbp.settings.local.conf` is loaded if it exists.
- [`ble.sh`]: A line editor for bash that provides features like syntax
  highlighting and auto-suggestions.
- [`kubectl-aliases`]: A library that provides a set of `kubectl` aliases for
  common `kubectl` commands. It is used in `.bash_aliases` to set the aliases.
- [`ssh-find-agent`]: A library that provides a way to find the ssh agent socket
  and set the `SSH_AUTH_SOCK` environment variable. If a running ssh-agent isn't
  found, it starts a new instance. It is used in `.bashrc` to set the
  `SSH_AUTH_SOCK` variable.

[`ble.sh`]: https://github.com/akinomyoga/ble.sh
[`sbp`]: https://github.com/brujoand/sbp
[`kubectl-aliases`]: https://github.com/ahmetb/kubectl-aliases
[`ssh-find-agent`]: https://github.com/wwalker/ssh-find-agent
