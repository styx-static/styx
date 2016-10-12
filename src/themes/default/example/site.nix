/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/

{ pkgs ? import <nixpkgs> {}
, styxLib
, renderDrafts ? false
, siteUrl ? null
, lastChange ? null
}@args:

# TODO This is for quick testing
# TODO Do not forget to restore to styxLib before push / release
let lib = import ../../../lib pkgs;
#let lib = import styxLib pkgs;
in with lib;

let

  /* Configuration loading
  */
  conf = let
    conf       = import ./conf.nix;
    themesConf = lib.themes.loadConf { inherit themes themesDir; };
    mergedConf = recursiveUpdate themesConf conf;
  in
    overrideConf mergedConf args;

  /* Site state
  */
  state = { inherit lastChange; };

  /* Load themes templates
  */
  templates = lib.themes.loadTemplates {
    inherit themes defaultEnvironment customEnvironments themesDir;
  };

  /* Load themes static files
  */
  files = lib.themes.loadFiles {
    inherit themes themesDir;
  };


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* Themes used
  */
  themes = [ "default" ];

  /* Themes location
  */
  themesDir = ../..;


/*-----------------------------------------------------------------------------
   Template enviroments

-----------------------------------------------------------------------------*/


  /* Default template environment
  */
  defaultEnvironment = { inherit conf state lib templates data; };

  /* Custom environments for specific templates
  */
  customEnvironments = {
    partials.head = defaultEnvironment // { feed = pages.feed; };
  };


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
   the data set is included in the template environment
-----------------------------------------------------------------------------*/

  substitutions = { inherit conf; };

  data = {
    # loading a single page
    about  = loadFile { dir = ./pages; file = "about.md"; };
    # loading a list of contents
    posts  = loadFolder { inherit substitutions; from = ./posts; };
    # loading a list of contents and adding attributes
    drafts = loadFolder { inherit substitutions; from = ./drafts; extraAttrs = { isDraft = true; }; };
    navbar = [ (head pages.archives) pages.about ];
    # creating taxonomies
    taxonomies = mkTaxonomyData { pages = pages.posts; taxonomies = [ "tags" "categories" ]; };
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {

    /* Index page
       Example of extending a page attribute set
    */
    index = {
      title = "Home";
      href = "index.html";
      template = templates.index;
      # Every attribute defined below is non standard
      inherit feed;
      posts = take conf.theme.index.numberOfPosts posts;
      archivePage = head archives;
    };

    /* About page
       Example of generating a page from imported data
    */
    about = {
      href = "about.html";
      template = templates.generic.full;
      # setting breadcrumbs
      breadcrumbs = [ index ];
    } // data.about;

    /* Post archives
       Example of splitting a page between a list of items
    */
    archives = splitPage {
      baseHref = "archives/posts";
      title = "Posts";
      template = templates.archive;
      items = posts;
      itemsPerPage = conf.theme.archive.postsPerPage;
    };

    /* RSS feed page
    */
    feed = {
      href = "feed.xml";
      template = templates.feed;
      # Showing only the last 10 posts in the feed
      posts = take 10 posts;
      # The feed page doesn't need a layout
      layout = id;
    };

    /* 404 error page
    */
    e404 = { href = "404.html"; template = templates.e404; title = "404"; };

    /* Posts pages (as a list of pages)
       Includes the drafts if renderDrafts is true
    */
    posts = let
      posts = data.posts ++ (optional renderDrafts data.drafts);
      # extend a post attribute set
      extendPosts = post: post // {
        template = templates.post.full;
        breadcrumbs = with pages; [ index (head archives) ];
        href = "posts/${post.fileData.basename}.html";
      };
      postPages = map extendPosts posts;
    in sortBy "date" "dsc" postPages;


    /* Generate taxonomy pages for posts tags and categories
    */
    taxonomies = mkTaxonomyPages {
      data = data.taxonomies;
      taxonomyTemplate = templates.taxonomy.full;
      termTemplate = templates.taxonomy.term.full;
    };

  };


/*-----------------------------------------------------------------------------
   generateSite arguments preparation

-----------------------------------------------------------------------------*/

  pagesList = let
    # converting pages attribute set to a list
    list = pagesToList pages;
    # setting a layout to pages without one
    in map (setDefaultLayout templates.layout) list;


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

in (generateSite { inherit files pagesList; })
