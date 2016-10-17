# Showcase theme

This is a theme for the Styx static site generator meant to show most of its functionalities with a basic design.

This theme is mostly using `site.nix` and only provide a very thin configuration interface.

## Features

### Navbar

The contents of `data.navbar` are automatically used to populate the navbar.

`data.navbar` should be a list of pages or sets with the `href` and `title` attribute:

```
data.navbar = [
  pages.about
  { title = "Styx"; href = "https://styx-static.github.io/styx-site/"; }
];
```

The brand part is managed by the theme `navbar.brand` setting.

### Breadcrumbs

If a page attribute set has a breadcrumb attribute, it will be used to generate breadcrumbs for this page.

```
pages.about = {
  href = "about.html";
  template = templates.generic.full;
  breadcrumbs = [ pages.index ];
} // data.about;
```

`breadcrumbs` must be a list of pages.

Note: It is possible to set a breadcrumb title different to the page title by adding a `breadcrumbTitle` attribute to the page.

```
pages.index = {
  ...
  breadcrumbTitle = templates.icon.fa "home";
};
```

### Icons

There are templates for bootstrap and font-wesome icons:

- `templates.icon.fa "home"` will display the home icon from font-awesome.
- `templates.icon.bs "file"` will display the file icon from bootstrap.


### Taxonomies

There are templates for taxonomies:

- `templates.taxonomies.full`: Display a taxonomy index page listing all its terms.
- `templates.taxonomies.full`: Display a taxonomy as a section like for the example site sidebar.
- `templates.taxonomies.inline`: Display a taxonomy for a value, like for posts pages in the example site.
- `templates.taxonomies.term.full`: Display a taxonomy term page listing all of its values.

Taxonomies data must be created in the `data` section and taxonomies pages must be declared in the `pages` section, see `example/site.nix` for an example.

### RSS Feed

Rss feeds can be created with the `templates.feed` template.

```
pages.feed = {
  href = "feed.xml";
  template = templates.feed;
  layout = id;
  items = take 10 pages.posts;
};
```

Rss feed must be passed a `items` list that contains the items to show in the feed.

Default layout template will automatically create a rss link in the head if `pages.feed` exists.


### Sitemap file

A sitemap.org compliant sitemap can be created with `templates.sitemap`, see `example/site.nix` for an example.


