# Bash configuration

This directory contains bash specific resource configuration, libraries, and
scripts.

## Features

- [SBP](https://github.com/brujoand/sbp) prompt in Tokyo Night color scheme with
  git, Python virtualenv, and Nix shell integration.
- [Bash completion](./_bash_completion) for `pip`, `kubectl`, and `aqua` in
  addition to the system default completions.
- [Bash aliases](./_bash_aliases) for common commands, including
  [`kubectl-aliases`](https://github.com/ahmetb/kubectl-aliases).
- `ssh-agent` integration to find the running ssh-agent and set the
  `SSH_AUTH_SOCK` environment variable.
- `tmux` integration to set the terminal title and display the current working
  directory in the status bar. Tmux session reuse is enabled by default.
- Integration with Google Cloud SDK, including `gcloud`, `gsutil`, and `bq`
  commands installed in `~/opt/google-cloud-sdk`.

## Bash resource configuration (`rc`)

Resource configuration for different purposes are broken into separate files
using their standard names, such as `.bash_aliases` and `.bash_completion`.

Machine local files can be created by suffixing `.local` to the file name and
putting it in your home directory. For example, `.bashrc` will load a script
called `.bashrc.local` if it exists. This goes for other scripts like
`.bash_aliases`, `.bash_completion`, etc.

Each resource configuration file is wrapped in a function that is called at the
end of the file. This allows for setting local variables that don't corrupt the
terminal session.

`.inputrc` contains shell key mappings.

## Bash libraries

The `lib` directory contains bash libraries that are used in resource
configuration etc..

- [`sbp`]: A simple bash prompt library that provides a simple way to customize
  the bash prompt. It is used in `.bashrc` to set the prompt.
- [`kubectl-aliases`]: A library that provides a set of kubectl aliases for
  common kubectl commands. It is used in `.bash_aliases` to set the aliases.
- [`ssh-find-agent`]: A library that provides a way to find the ssh agent socket
  and set the `SSH_AUTH_SOCK` environment variable. If a running ssh-agent isn't
  found, it starts a new instance. It is used in `.bashrc` to set the
  `SSH_AUTH_SOCK` variable.

[`sbp`]: https://github.com/brujoand/sbp
[`kubectl-aliases`]: https://github.com/ahmetb/kubectl-aliases
[`ssh-find-agent`]: https://github.com/wwalker/ssh-find-agent
