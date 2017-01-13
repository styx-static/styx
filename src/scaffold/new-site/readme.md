# Welcome to your new styx site!

## Start

The `site.nix` in this folder generate an empty site.


## First steps

Find the line saying `themes = [ ];` in `site.nix` and change it with the following to enable the showcase theme:

```
  themes = [ styx-themes.showcase ];
```

Showcase theme provide a design and a set of templates, but there is no content to generate yet.

So let's create a page, pages are declared in the pages attribute set. We will start with a  basic "Hello world!" index page:

```
  pages = {
 
    index = {
      title    = "Hello world!";
      content  = "<p>Hello world!</p>";
      path     = "/index.html";
      template = templates.generic.full;
      layout   = templates.layout;
    };

  };
```

The site can be previewed with `styx preview`!

This is just the beginning, take a look at the showcase [example site.nix](https://github.com/styx-static/styx-theme-showcase/blob/master/example/site.nix) to see examples of more complex pages and data handling.

The showcase theme is pretty feature heavy, so you might want to start with a simpler theme like [Hyde](https://github.com/styx-static/styx-theme-hyde) or [Agency](https://github.com/styx-static/styx-theme-agency).

All available themes can be found in the [themes repository](https://github.com/styx-static/themes).

The documentation for the current version of styx can be opened in a browser by running the `styx manual` command.

Have fun!
