# Welcome to your new styx site!

## Start

First you need to install a theme, the showcase theme provide an example site the show most of the styx functionalities.

To get it, run:

```
git clone https://github.com/styx-static/styx-theme-showcase.git themes/showcase
```

Then, you can preview the example site of the showcase by running `styx preview --target themes/showcase/example`.


## Next

Copy the example `site.nix` to this directory, `cp themes/showcase/example/site.nix ./` and edit it to adjust the `themesDir` setting to `./themes`:

```
  themesDir = ./themes;
```

The showcase theme is pretty feature heavy, so you might want to start with a simpler theme like [Hyde](https://github.com/styx-static/styx-theme-hyde) or [Agency](https://github.com/styx-static/styx-theme-agency).

Read the [documentation](https://styx-static.github.io/styx-site/documentation.html) to learn more in details how to use styx.

Have fun!
