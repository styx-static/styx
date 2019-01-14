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

### Styx

Running styx dev version:

```
$ nix-build styx
$ result/bin/styx --version
```

Styx is just a shell script wrapping `nix-build`, the `--DEBUG` flag can be passed to see executed commands (`set -x`).

### Themes

Previewing the dev version showcase theme example site:

```
$ $(nix-build --no-out-link)/bin/styx preview-theme showcase
```

Decomposing the command:

- `$(nix-build --no-out-link styx)/bin/styx`: build styx dev version from `default.nix`, and call the styx executable in it.
- `preview-theme showcase`: `preview-theme` is the command to preview a theme example site on a local server.

Loading the showcase example site in `nix repl`:

```
$ nix repl ./nixpkgs

nix-repl> site = callPackage (import "${(import styx.themes).showcase}/example/site.nix") {}

nix-repl> site.conf
{ siteUrl = "https://styx-static.github.io/styx-theme-showcase"; theme = { ... }; }
```

## Commit policy

Please run the tests before any commit:

```
$ scripts/run-tests
```
