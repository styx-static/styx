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

  data = with lib.data;
  with lib.lib; {
    # loading a single page
    about = loadFile {
      file = "${pkgs.styx}/src/data/presets/sample-data//pages/about.md";
      inherit env;
    };

    # loading a list of contents
    posts = lib.utils.sortBy "date" "dsc" (loadDir {
      dir = "${pkgs.styx}/src/data/presets/sample-data/posts";
      inherit env;
    });

    # menu declaration
    menu = [pages.about];
  };

  /*
    -----------------------------------------------------------------------------
     Pages

     This section declares the pages that will be generated
  -----------------------------------------------------------------------------
  */

  pages = with lib.pages;
  with lib.lib; rec {
    /*
    Index page
    Splitting a list of items through multiple pages
    For more complex needs, mkSplitCustom is available
    */
    index = mkSplit {
      title = "Home";
      basePath = "/index";
      inherit (conf.theme) itemsPerPage;
      template = templates.index;
      data = posts.list;
    };

    /*
    About page
    Example of generating a page from imported data
    */
    about =
      {
        path = "/about.html";
        template = templates.page.full;
      }
      // data.about;

    /*
    Feed page
    */
    feed = {
      path = "/feed.xml";
      template = templates.feed.atom;
      # Bypassing the layout
      layout = id;
      items = take 10 posts.list;
    };

    /*
    404 error page
    */
    e404 = {
      path = "/404.html";
      template = templates.e404;
    };

    /*
    Posts pages
    */
    posts = mkPageList {
      data = data.posts;
      pathPrefix = "/posts/";
      template = templates.post.full;
      breadcrumbs = [(head pages.index)];
    };
  };

  /*
    -----------------------------------------------------------------------------
     Site rendering

  -----------------------------------------------------------------------------
  */

  # converting pages attribute set to a list
  pageList = lib.generation.pagesToList {
    inherit pages;
    default = {inherit (templates) layout;};
  };

  site = lib.generation.mkSite {inherit files pageList;};
}
