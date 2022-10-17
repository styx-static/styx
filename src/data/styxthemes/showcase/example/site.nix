/*
  -----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------
*/
{
  pkgs ? import <nixpkgs> {},
  extraConf ? {},
}: rec {
  /*
    -----------------------------------------------------------------------------
     Setup

     This section setup required variables
  -----------------------------------------------------------------------------
  */

  styx = import pkgs.styx {
    # Used packages
    inherit pkgs;

    # Used configuration
    config = [./conf.nix extraConf];

    # Loaded themes
    themes = let
      styx-themes = import pkgs.styx.themes;
    in [
      styx-themes.generic-templates
      ../.
    ];

    # Environment propagated to templates
    env = {inherit data pages;};
  };

  # Propagating initialized data
  inherit (styx.themes) conf files templates env lib;

  /*
    -----------------------------------------------------------------------------
     Data

     This section declares the data used by the site
  -----------------------------------------------------------------------------
  */

  data = with lib; {
    # loading a single page
    about = loadFile {
      file = "${pkgs.styx}/src/scaffold/sample-data/pages/about.md";
      inherit env;
    };

    # loading a list of contents
    posts = sortBy "date" "dsc" (loadDir {
      dir = "${pkgs.styx}/src/scaffold/sample-data/posts";
      inherit env;
    });

    # Navbar data
    navbar = [
      pages.about
      (head pages.postsArchive)
      (pages.feed // {navbarTitle = "RSS";})
      {
        title = "Styx";
        url = "https://styx-static.github.io/styx-site/";
      }
    ];

    # posts taxonomies
    taxonomies.posts = mkTaxonomyData {
      data = pages.posts.list;
      taxonomies = ["tags" "level"];
    };
  };

  /*
    -----------------------------------------------------------------------------
     Pages

     This section declares the pages that will be generated
  -----------------------------------------------------------------------------
  */

  pages = with lib.pages; rec {
    /*
    Index page
    Example of splitting a list of items through multiple pages
    For more complex needs, mkSplitCustom is available
    */
    index = mkSplit {
      title = conf.theme.site.title;
      basePath = "/index";
      itemsPerPage = conf.theme.index.itemsPerPage;
      template = templates.index;
      data = pages.posts.list;
      breadcrumbTitle = templates.icon.font-awesome "home";
    };

    /*
    About page
    Example of generating a page from a piece of data
    */
    about =
      {
        path = "/about.html";
        template = templates.page.full;
        # setting breadcrumbs
        breadcrumbs = [(lib.head index)];
      }
      // data.about;

    /*
    RSS feed page
    */
    feed = {
      path = "/feed.xml";
      template = templates.feed.atom;
      # Bypassing the layout
      layout = lib.id;
      items = lib.take 10 pages.posts.list;
    };

    /*
    404 error page
    */
    e404 = {
      path = "/404.html";
      template = templates.e404;
      title = "404";
    };

    /*
    Posts pages (as a list of pages)

    mkPageList is a convenience function to generate a list of page from a
    list of data
    */
    posts = mkPageList {
      data = data.posts;
      pathPrefix = "/posts/";
      template = templates.post.full;
      breadcrumbs = [(lib.head index)];
    };

    postsArchive = mkSplit {
      title = "Archives";
      basePath = "/archive/post";
      template = templates.archive;
      breadcrumbs = [(lib.head index)];
      itemsPerPage = conf.theme.archives.itemsPerPage;
      data = pages.posts.list;
    };

    /*
    Taxonomy related pages
    */
    taxonomies = mkTaxonomyPages {
      data = data.taxonomies.posts;
      taxonomyTemplate = templates.taxonomy.full;
      termTemplate = templates.taxonomy.term.full;
    };
  };

  /*
  Sitemap
  The sitemap is out of the pages attribute set because it has to loop
  through all the pages
  */
  sitemap = {
    path = "/sitemap.xml";
    template = templates.sitemap;
    layout = lib.id;
    pages = pageList;
  };

  /*
    -----------------------------------------------------------------------------
     Site rendering

  -----------------------------------------------------------------------------
  */

  # converting pages attribute set to a list
  pageList = lib.pagesToList {
    inherit pages;
    default.layout = templates.layout;
  };

  /*
  Substitutions
  */
  substitutions = {
    siteUrl = conf.siteUrl;
  };

  site = lib.mkSite {
    inherit files substitutions;
    pageList = pageList ++ [sitemap];
    meta = (import ./meta.nix) {inherit lib;};
  };
}
