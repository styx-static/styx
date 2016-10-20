# Welcome to your new styx site!

## Start

The `site.nix` in this folder generate an empty site.

First you need to install a theme, the showcase theme provide an example site that show most of styx functionalities.

To get it, run:

```
git clone https://github.com/styx-static/styx-theme-showcase.git themes/showcase
```

Then, the showcase theme example site can be previewed by running `styx preview --in themes/showcase/example`.


## First steps

Find the line saying `themes = [ ];` in this directory `site.nix` and change it with the following to enable the showcase theme:

```
  themes = [ "showcase" ];
```

Showcase theme provide a  design and a set of templates, but there is no content to generate yet.

So let's create a page, pages are declared in the pages attribute set. We will start with a  basic "Hello world!" index page:

```
  pages = {
 
    index = {
      title    = "Hello world!";
      content  = "<p>Hello world!</p>";
      href     = "index.html";
      template = templates.generic.full;
      layout   = templates.layout;
    };

  };
```

The site can be previewed with `styx preview`!

This is just the beginning, take a look at the showcase example `themes/showcase/example/site.nix` to see examples of more complex pages and data handling.

The showcase theme is pretty feature heavy, so you might want to start with a simpler theme like [Hyde](https://github.com/styx-static/styx-theme-hyde) or [Agency](https://github.com/styx-static/styx-theme-agency).

Read the [documentation](https://styx-static.github.io/styx-site/documentation.html) to learn more in details how to customize your site!

Have fun!
