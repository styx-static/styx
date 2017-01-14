# Showcase theme

This is a theme for the Styx static site generator meant to show most of its functionalities with a basic design.

This theme is mostly using `site.nix` and only provide a very thin configuration interface.

## Preview

![Preview](/screen.png)

## Features

### Navbar

The contents of `data.navbar` are automatically used to populate the navbar.

`data.navbar` should be a list of pages or sets with the `href` and `title` attribute:

```
  data.navbar = [
    pages.about
    (head pages.postsArchive)
    (pages.feed // { navbarTitle = "RSS"; })
    { title = "Styx"; url = "https://styx-static.github.io/styx-site/"; }
  ];
```

### Breadcrumbs

If a page attribute set has a breadcrumb attribute, it will be used to generate breadcrumbs for this page.

```
pages.about = {
  ...
  breadcrumbs = [ (lib.head index) ];
};
```

`breadcrumbs` must be a list of pages.

Note: It is possible to set a breadcrumb title different to the page title by adding a `breadcrumbTitle` attribute to the page.

```
pages.index = {
  ...
  breadcrumbTitle = templates.icon.font-awesome "home";
};
```
