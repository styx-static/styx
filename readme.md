# Styx

Static site generator in Nix expression language.

Styx developement version can be tested with the Nix package manager `nix-shell` command:

```
$ nix-shell -p $(nix-build https://github.com/styx-static/styx/archive/master.tar.gz)
$ styx --help
```

Styx can be installed with the `nix-env` command:

```
$ nix-env -i $(nix-build https://github.com/ericsagnes/styx/archive/master.tar.gz)
$ styx --help
```

To open the latest documentation in the default browser, run the following command:

```
$BROWSER $(nix-build --no-out-link https://github.com/styx-static/styx/archive/master.tar.gz)/share/doc/styx/index.html
```
