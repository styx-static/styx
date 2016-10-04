# Styx

Static site generator in Nix expression language.

This is early state work, but can be tested with the Nix package manager `nix-shell` command:

```
$ nix-shell -p `nix-build https://github.com/ericsagnes/styx/archive/master.tar.gz`
$ styx --help
```

It is possible to open the latest documentation in the default browser with the following command:

```
$BROWSER $(nix-build --no-out-link https://github.com/ericsagnes/styx/archive/master.tar.gz)/share/doc/styx/index.html
```
