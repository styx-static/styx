# Welcome to your new styx site!

## Start

The `site.nix` in this folder generate an empty site.


## First steps

Find the line saying `themes = [ ];` in `site.nix` and change it with the following to enable the generic-templates theme:

```nix
  themes = [
    styx-themes.generic-templates
  ];
```

Generic-templates theme provide a design and a set of templates, but there is no content to generate yet.

So let's create a page, pages are declared in the pages attribute set. We will start with a  basic "Hello world!" index page:

```
  pages = {

    index = {
      title    = "Hello world!";
      content  = "<p>Hello world!</p>";
      path     = "/index.html";
      template = templates.page.full;
      layout   = templates.layout;
    };

  };
```

Then, a preview of the site can be launch by running `styx preview`.

The documentation for the current version of styx can be launched in a browser by running the `styx doc` command.
The `styx-themes` packages set, that contains themes with example sites, documentation can also be found in the in styx documentation.

Have fun!
