# Contributing to Styx

Thank you for being interested in contributing to this project!
Feel free to ask questions on the [issue tracker](https://github.com/styx-static/styx/issues).

## Setting up a development environment

Setting up a development environment requires [`nix`](https://nixos.org/nix/).

### Preparation

#### Getting the repository

Clone this repository:

```
$ git clone https://github.com/styx-static/styx.git
```

### Devshell

Enter the devshell:

```
$ direnv allow || nix develop -c "$SHELL"
```

### Styx

Running styx dev version:

```
$ nix run . -- --version
```

Styx is just a shell script wrapping `nix-build`, the `--DEBUG` flag can be passed to see executed commands (`set -x`).

### Themes

Previewing the dev version showcase theme example site:

```
$ nix run . -- preview-theme showcase
```

Loading the showcase example site in `nix repl`:

```
$ nix repl ./repl.nix
> themes = out.data.styxthemes

nix-repl> site = import "${themes.showcase}"/example/site.nix {}

nix-repl> site.conf
{ siteUrl = "https://styx-static.github.io/styx-theme-showcase"; theme = { ... }; }
```

## Commit policy

Please run the tests before any commit:

```
$ nix run .#run-tests
```
