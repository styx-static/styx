/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ lib, styx, styx-themes, runCommand, writeText
, renderDrafts ? false
, siteUrl ? null
}@args:

let styxLib = import "${styx}/share/styx/lib" {
  inherit lib;
  pkgs = { inherit styx runCommand writeText; };
};
in with styxLib;

let

  /* Configuration loading
  */
  conf = let
    conf       = import ./conf.nix;
    themesConf = styxLib.themes.loadConf themes;
    mergedConf = recursiveUpdate themesConf conf;
  in
    overrideConf mergedConf args;

  /* Load themes templates
  */
  templates = styxLib.themes.loadTemplates {
    inherit themes defaultEnvironment customEnvironments;
  };

  /* Load themes static files
  */
  files = styxLib.themes.loadFiles themes;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* Themes used
  */
  themes = [ ../. ];


/*-----------------------------------------------------------------------------
   Template environments

-----------------------------------------------------------------------------*/

  /* Default template environment
  */
  defaultEnvironment = { inherit conf templates data pages; lib = styxLib; };

  /* Custom environments for specific templates
  */
  customEnvironments = {
  };


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
   the data set is included in the default template environment
-----------------------------------------------------------------------------*/

  data = {
    # loading a single page
    about  = loadFile { dir = ./data/pages; file = "about.md"; };
    # loading a list of contents
    posts  = let
      postsList = loadDir { dir = ./data/posts; };
      # include drafts only when renderDrafts is true
      draftsList = optionals renderDrafts (loadDir { dir = ./data/drafts; isDraft = true; });
    in sortBy "date" "dsc" (postsList ++ draftsList);
    # Navbar data
    navbar = [
      pages.about
      (head pages.postsArchive)
      { title = "RSS";  href = "${conf.siteUrl}/${pages.feed.href}"; }
      { title = "Styx"; href = "https://styx-static.github.io/styx-site/"; }
    ];
    # posts taxonomies
    taxonomies.posts = mkTaxonomyData { data = pages.posts; taxonomies = [ "tags" "level" ]; };
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {

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
      breadcrumbs = [ (head index) ];
    } // data.about;

    /* RSS feed page
    */
    feed = {
      href = "feed.xml";
      template = templates.feed;
      # Bypassing the layout
      layout = id;
      items = take 10 pages.posts;
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
      breadcrumbs = [ (head pages.index) ];
    };

    postsArchive = mkSplit {
      title = "Archives";
      baseHref = "archive/post";
      template = templates.archive;
      breadcrumbs = [ (head index) ];
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
      breadcrumbs = [ (head pages.index) ];
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
    layout = id;
    urls = pagesToList pages;
  };
  


/*-----------------------------------------------------------------------------
   generateSite arguments preparation

-----------------------------------------------------------------------------*/

  pagesList = let
    # converting pages attribute set to a list
    list = (pagesToList pages) ++ [ sitemap ];
    # setting a default layout
    in map (setDefaultLayout templates.layout) list;

  /* Substitutions
  */
  substitutions = {
    siteUrl = conf.siteUrl;
  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

in generateSite { inherit files pagesList substitutions; }
