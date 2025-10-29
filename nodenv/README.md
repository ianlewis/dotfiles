# Node tools

This directory defines dependencies for various Node.js tools that are installed
in a global `node_modules` directory. The tools are installed in a
`node_modules` within this folder. The directory is then linked to
`~/.local/share/node_modules` and `~/.local/share/node_modules/.bin` is added to
the `$PATH` so that the tools can be run from anywhere.
