/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ lib, styx, runCommand, writeText
, styx-themes
, extraConf ? {}
}@args:

rec {

  /* Library loading
  */
  styxLib = import styx.lib args;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* list the themes to load, paths or packages can be used
     items at the end of the list have higher priority
  */
  themes = [
    ../.
  ];

  /* Loading the themes data
  */
  themesData = styxLib.themes.load {
    inherit styxLib themes;
    templates.extraEnv = { inherit data pages; };
    conf.extra = [ (import ./conf.nix) extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = with lib; {

    # loading a single page
    about  = loadFile { dir = ./data/pages; file = "about.md"; };

    # loading a list of contents
    posts  = let
      postsList = loadDir { dir = ./data/posts; };
      # include drafts only when renderDrafts is true
      draftsList = optionals (conf ? renderDrafts) (loadDir { dir = ./data/drafts; isDraft = true; });
    in sortBy "date" "dsc" (postsList ++ draftsList);

    # Navbar data
    navbar = [
      pages.about
      (head pages.postsArchive)
      { title = "RSS";  href = "${conf.siteUrl}/${pages.feed.href}"; }
      { title = "Styx"; href = "https://styx-static.github.io/styx-site/"; }
    ];

    # posts taxonomies
    taxonomies.posts = mkTaxonomyData {
      data = pages.posts;
      taxonomies = [ "tags" "level" ];
    };

  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = with lib.pages; rec {

    /* Index page
       Example of splitting a list of items through multiple pages
       For more complex needs, mkSplitCustom is available
    */
    index = mkSplit {
      title = conf.theme.site.title;
      baseHref = "index";
      itemsPerPage = conf.theme.index.itemsPerPage;
      template = templates.index;
      data = pages.posts;
      breadcrumbTitle = templates.icon.fa "home";
    };

    /* About page
       Example of generating a page from a piece of data
    */
    about = {
      href = "about.html";
      template = templates.generic.full;
      # setting breadcrumbs
      breadcrumbs = [ (lib.head index) ];
    } // data.about;

    /* RSS feed page
    */
    feed = {
      href = "feed.xml";
      template = templates.feed;
      # Bypassing the layout
      layout = lib.id;
      items = lib.take 10 pages.posts;
    };

    /* 404 error page
    */
    e404 = { href = "404.html"; template = templates.e404; title = "404"; };

    /* Posts pages (as a list of pages)

       mkPageList is a convenience function to generate a list of page from a
       list of data
    */
    posts = mkPageList {
      data = data.posts;
      hrefPrefix = "posts/";
      template = templates.post.full;
      breadcrumbs = [ (lib.head pages.index) ];
    };

    postsArchive = mkSplit {
      title = "Archives";
      baseHref = "archive/post";
      template = templates.archive;
      breadcrumbs = [ (lib.head index) ];
      itemsPerPage = 15;
      data = pages.posts;
    };

    /* Subpages of multi-pages posts

       subpages are not included in posts because we do not want to have the
       subpages in the rss feed or posts list
    */
    postsMultiTail = mkMultiTail {
      data = data.posts;
      hrefPrefix = "posts/";
      template = templates.post.full;
      breadcrumbs = [ (lib.head pages.index) ];
    };

    /* Taxonomy related pages
    */
    taxonomies = mkTaxonomyPages {
      data = data.taxonomies.posts;
      taxonomyTemplate = templates.taxonomy.full;
      termTemplate = templates.taxonomy.term.full;
    };

  };

  /* Sitemap
     The sitemap is out of the pages attribute set because it has to loop
     through all the pages
  */
  sitemap = {
    href = "sitemap.xml";
    template = templates.sitemap;
    layout = lib.id;
    urls = lib.pagesToList { inherit pages; };
  };

/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  pagesList = 
    # converting pages attribute set to a list
    (lib.pagesToList {
      inherit pages;
      default = { layout = templates.layout; };
    })
    ++ [ sitemap ];

  /* Substitutions
  */
  substitutions = {
    siteUrl = conf.siteUrl;
  };

  site = lib.generateSite {
    inherit files pagesList substitutions;
    meta = (import ./meta.nix) { inherit lib; };
  };

}
