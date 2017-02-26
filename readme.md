[![Build Status](https://travis-ci.org/styx-static/styx.svg?branch=master)](https://travis-ci.org/styx-static/styx)

# Styx

The purely functional static site generator in Nix expression language.

## Install

Use nix-env to install styx, or nix-shell to just test without installing it:

```sh
$ nix-env -iA styx
$ styx --help
```

```sh
$ nix-shell -p styx
$ styx --help
```

The version you will get will depend on the version of nixpkgs used, to get the latest stable release without relying on nixpkgs:

```
$ nix-env -i $(nix-build https://github.com/styx-static/styx/archive/latest.tar.gz)
$ styx --help
```

or

```
$ nix-shell -p $(nix-build https://github.com/styx-static/styx/archive/latest.tar.gz)
$ styx --help
```

Note: When using a version of styx that is different of the one in the system active nixpkgs, call to `pkgs.styx-themes.*` might not work as versions will differ.  
In this case themes should be fetched directly with `fetchGit` or similar.

## Links

- [Official site](https://styx-static.github.io/styx-site/)
- [Documentation](https://styx-static.github.io/styx-site/documentation/)


## Contributing

Read [contributing.md](./contributing.md) for details.
