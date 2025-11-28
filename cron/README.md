# `crontab`

The base `crontab` is managed by `dotfiles` and is generated and installed using
`make configure-crontab`. User-specific `crontab` files can be added in the
`~/.config/dotfiles/crontab/` directory. Each file in this directory corresponds
to a user-specific `crontab` and will be merged into the user's `crontab`.
