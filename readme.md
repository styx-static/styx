[![Build Status](https://travis-ci.org/styx-static/styx.svg?branch=master)](https://travis-ci.org/styx-static/styx)

# Styx

Static site generator in Nix expression language.

Styx latest stable version can be tested with the Nix package manager `nix-shell` command:

```
$ nix-shell -p $(nix-build https://github.com/styx-static/styx/archive/latest.tar.gz)
$ styx --help
```

Styx can be installed with the `nix-env` command:

```
$ nix-env -i $(nix-build https://github.com/styx-static/styx/archive/latest.tar.gz)
$ styx --help
```

To open the latest documentation in the default browser, run the following command:

```
$BROWSER $(nix-build --no-out-link https://github.com/styx-static/styx/archive/latest.tar.gz)/share/doc/styx/index.html
```

## Links

- [Official site](https://styx-static.github.io/styx-site/)
- [Documentation](https://styx-static.github.io/styx-site/documentation.html)

## Contributing

Read [contributing.md](./contributing.md) for details.
