# Contribute to Styx

## Setting up a development environment

Setting up a development environment requires to have `nix` and to clone a few repositories.

### Preparation

#### Creating a folder to hold the repositories

```
$ mkdir styx-dev && cd styx-dev
```

#### Getting the repositories

Two repositories are required:

- This one, the dev version of styx
- Styx-themes, the dev version of themes

```
$ git clone https://github.com/styx-static/styx.git
$ git clone https://github.com/styx-static/themes.git --recursive
```

## Running dev versions

Note: All commands are run from the `styx-dev` folder.

### Styx

```
$ nix-build styx
$ ./result/bin/styx --version
```

Styx is just a shell script wrapping `nix-build`, to see what commands are passed the `--DEBUG` flag can be passed.

### Themes

Previewing the local version showcase example site

```
$ $(nix-build --no-out-link styx)/bin/styx preview --in $(nix-build --no-out-link -A styx-themes.showcase ./styx/nixpkgs)/example --arg pkgs "import ./styx/nixpkgs"
```

Decomposing the command:

- `$(nix-build --no-out-link styx)/bin/styx`: build styx folder `default.nix` and call the styx executable in it.
- `preview --in`: `preview` is a styx to preview a site on a local server, `--in` specifies the path of the styx site.
- `$(nix-build --no-out-link -A styx-themes.showcase ./styx/nixpkgs)/example`: this `nix-build` build the dev version of the showcase theme defined in `./styx/nixpkgs/default.nix`.
- `--arg pkgs "import ./styx/nixpkgs"` tells the styx builder to use the local dev version of styx and themes.

Loading a local version showcase example site in `nix-repl`:

```
nix-repl ./styx/nixpkgs

nix-repl> site = callPackage (import "${styx-themes.showcase}/example/site.nix") {}

nix-repl> site.conf
{ siteUrl = "https://styx-static.github.io/styx-theme-showcase"; theme = { ... }; }
```

## Commit policy

Run the tests before any commit:

```
$  ./styx/scripts/run-tests
```

