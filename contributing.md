# Contributing to Styx

Thank you for being interested in contributing to this project!  
Feel free to ask questions on the issue tracker.

## Setting up a development environment

Setting up a development environment requires to have `nix`.

### Preparation

#### Getting the repository

Clone this repository:

```
$ git clone https://github.com/styx-static/styx.git --recursive
```

### Styx

Running styx dev version:

```
$ nix-build styx
$ ./result/bin/styx --version
```

Styx is just a shell script wrapping `nix-build`, to see what used commands use the `--DEBUG` flag can be passed.

### Themes

Previewing the dev version showcase theme example site:

```
$ $(nix-build --no-out-link)/bin/styx preview --in ./themes/showcase/example --arg pkgs "import ./nixpkgs"
```

Decomposing the command:

- `$(nix-build --no-out-link styx)/bin/styx`: build styx dev version from `default.nix`, and call the styx executable in it.
- `preview --in`: `preview` is a command to preview a site on a local server, `--in` specifies where to find the site file.
- `./themes/showcase/example`: Use the dev version of the showcase theme.
- `--arg pkgs "import ./nixpkgs"` tells the styx builder to use the local dev version of nixpkgs styx.

Loading a local version showcase example site in `nix-repl`:

```
nix-repl ./nixpkgs

nix-repl> site = callPackage (import "${styx-themes.showcase}/example/site.nix") {}

nix-repl> site.conf
{ siteUrl = "https://styx-static.github.io/styx-theme-showcase"; theme = { ... }; }
```

## Commit policy

Run the tests before any commit:

```
$  ./scripts/run-tests
```

