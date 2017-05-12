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


## Nix usages

This repository is also a playground for more exotic nix usages and experiments:

- [derivation.nix](./derivation.nix) is the main builder for styx, it builds the command line interface, the library and the documentation.

- [nixpkgs/default.nix](./nixpkgs/default.nix) extend the system nixpkgs with the styx related packages making it easy to build or install dev versions with the correct set of dependencies:

    ```
    $ nix-build nixpkgs -A styx
    $ nix-build nixpkgs -A styx-themes.showcase
    ```

- [script/run-tests](./scripts/run-tests) is a thin wrapper to `nix-build` that will run [library](./tests/lib.nix) and [functionality tests](./tests/default.nix).

- Library functions and themes templates use special functions (`documentedFunction` and `documentedTemplate`) that allow to automatically generate documentation and tests.  
The code used to generate tests from `documentedFunctions` can be found in [tests/lib.nix](./tests/lib.nix).  
Library function tests can print a coverage or a report (with pretty printing):

    ```
    $ cat $(nix-build --no-out-link -A coverage tests/lib.nix)
    $ cat $(nix-build --no-out-link -A report tests/lib.nix)
    ```

- [scripts/library-doc.nix](./scripts/library-doc.nix) is a nix expression that generate an asciidoc documentation from the library `documentedFunction`s ([example](https://styx-static.github.io/styx-site/documentation/library.html)).

- [scripts/update-themes-screens](./scripts/update-themes-screens) is a shell script using a `nix-shell` shebang that automatically take care of external dependencies (PhantomJS and image magick) that build every theme site, run it on a local server and take a screenshot with PhantomJS. neat!

- [scripts/themes-doc.nix](./scripts/themes-doc.nix) and [src/nix/site-doc.nix](./src/nix/site-doc.nix) are nix expressions that automatically generate documentation for styx themes, including configuration interface and templates ([example](https://styx-static.github.io/styx-site/documentation/styx-themes.html)). This feature is leveraged in the `styx site-doc` command to dynamically generate the documentation for a site according to used themes.

- `lib.prettyNix` is a pure nix function that pretty print nix expressions.

- [parsimonious](https://github.com/erikrose/parsimonious) is used to do some [voodoo](src/tools/parser.py) on markup files to turn them into valid nix expressions, so nix expressions can be embedded in markdown or asciidoc.

- styx `propagatedBuildInputs` are taken advantage in `lib.data` conversion functions like `markupToHtml`.


## Links

- [Official site](https://styx-static.github.io/styx-site/)
- [Documentation](https://styx-static.github.io/styx-site/documentation/)


## Contributing

Read [contributing.md](./contributing.md) for details.
