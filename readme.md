# Styx

![Build Status](https://github.com/styx-static/styx/workflows/Build/badge.svg)

The purely functional static site generator written in the Nix expression language.


## Features

Among other things, Styx has the following features:

### Easy to get started

Styx has no other dependency than Nix, if Nix is installed, run the following to use Styx:

```ShellSession
# if using flakes
$ nix shell github:styx-static/styx
# otherwise
$ nix-shell -p styx
```

### Multiple content support

Styx supports content in Markdown, AsciiDoc and Nix format.
Styx also extends AsciiDoc and Markdown with custom operators that can split a single markup file into many pages.

### Embedded nix

Nix can be [embedded in markup files](https://styx-static.github.io/styx-theme-showcase/posts/2016-09-17-media.html)!

### Handling of sass/scss

Upon site rendering, Styx will automatically convert SASS and SCSS files.

### Template framework

The `generic-template` theme provides a template framework that can be leveraged to easily create new themes or sites.
Thank to this a theme like Hyde consists only in about 120 lines of Nix templates.

### Configuration interface

Styx sites use a configuration interface à la NixOS modules.
Every configuration declaration is type-checked, and documentation can be generated from that interface.

### Linkcheck

Linkcheck functionality is available out of the box, just run `styx linkcheck` to run [linkchecker](https://wummel.github.io/linkchecker/) on a site.

### Themes

Styx supports themes. Multiple themes can be used, mixed and extended at the same time.
This makes it very easy to adapt an existing theme.
Official themes can also be used without any implicit installation, declaring the used theme(s) in `site.nix` is enough!

### Documentation

Styx embeds its complete documentation that can be viewed at any time by running `styx doc`.
A very unique feature of Styx is that it can generate the documentation for a site with the `styx site-doc`.


## Install

Use `nix-env` to install Styx, or `nix-shell` to just test without installing it:

```sh
$ nix-env -iA styx
$ styx --help
```

```sh
$ nix-shell -p styx
$ styx --help
```

The version you will get will depend on the version of nixpkgs used. To get the latest stable release without relying on nixpkgs:

```
$ nix-env -i $(nix-build https://github.com/styx-static/styx/archive/latest.tar.gz)
$ styx --help
```

or

```
$ nix-shell -p $(nix-build https://github.com/styx-static/styx/archive/latest.tar.gz)
$ styx --help
```

## Examples

The official Styx site is an example of a basic software site with release news. It has some interesting features like:

- generating the documentation for every version of styx
- generating a page for every official theme

See [site.nix](https://github.com/styx-static/styx-site/blob/master/site.nix) for implementation details.


## As a Nix laboratory

This repository is also a playground for more exotic nix usages and experiments:

- [derivation.nix](./derivation.nix) is the main builder for styx, it builds the command line interface, the library, styx themes and the documentation.

- Library functions and theme templates use special functions (`documentedFunction` and `documentedTemplate`) that allow automatically generating documentation and tests.
The code used to generate tests from `documentedFunctions` can be found in [tests/lib.nix](./tests/lib.nix).
Library function tests can print a coverage or a report (with pretty printing):

    ```
    $ cat $(nix-build --no-out-link -A coverage tests/lib.nix)
    $ cat $(nix-build --no-out-link -A report tests/lib.nix)
    ```

- [scripts/library-doc.nix](./scripts/library-doc.nix) is a nix expression that generate an AsciiDoc documentation from the library `documentedFunction`s ([example](https://styx-static.github.io/styx-site/documentation/library.html)).

- [scripts/themes-doc.nix](./scripts/themes-doc.nix) and [src/nix/site-doc.nix](./src/nix/site-doc.nix) are nix expressions that automatically generate documentation for styx themes, including configuration interface and templates ([example](https://styx-static.github.io/styx-site/documentation/styx-themes.html)). This feature is leveraged in the `styx site-doc` command to dynamically generate the documentation for a site according to used themes.

- `lib.prettyNix` is a pure nix function that pretty print nix expressions.

- [parsimonious](https://github.com/erikrose/parsimonious) is used to do some [voodoo](src/tools/parser.py) on markup files to turn them into valid nix expressions, so nix expressions can be embedded in Markdown or AsciiDoc.

- styx `propagatedBuildInputs` are taken advantage in `lib.data` conversion functions like `markupToHtml`.


## Links

- [Official site](https://styx-static.github.io/styx-site/)
- [Documentation](https://styx-static.github.io/styx-site/documentation/)


## Contributing

See [contributing.md](./contributing.md).


## Feedback

Any question or issue should be posted in the [github issue tracker](https://github.com/styx-static/styx/issues).
Themes and features requests are welcome!
And please let me know if you happen to run a site on styx!
