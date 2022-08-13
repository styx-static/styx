/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ pkgs ? import <nixpkgs> {}
, extraConf ? {}
}:

rec {

/*-----------------------------------------------------------------------------
   Setup

   This section setup required variables
-----------------------------------------------------------------------------*/

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
    env = { inherit data pages; };
  };

  # Propagating initialized data
  inherit (styx.themes) conf files templates env lib;

/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = with lib; {
    # Loading the index page data 
    index = loadFile { file = ./data/index.nix; inherit env; };

    # loading a single page
    about  = loadFile { file = "${pkgs.styx}/share/styx/scaffold/sample-data/pages/about.md"; inherit env; };

    # loading a list of contents
    posts  = sortBy "date" "dsc" (loadDir { dir = "${pkgs.styx}/share/styx/scaffold/sample-data/posts"; inherit env; });

    # menu declaration
    menu = with pages; [
      (about // { navbarTitle = "~/about"; })
      ((head postsList) // { navbarTitle = "~/posts"; })
    ];
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = with lib; rec {

    /* Custom index page
       See data/index.nix for the details
    */
    index = {
      title    = "styx@styx ~ $";
      path     = "/index.html";
      template = id;
    } // data.index;

    /* About page
       Example of generating a page from imported data
    */
    about = {
      path     = "/about.html";
      template = templates.page.full;
    } // data.about;

    /* Feed page
    */
    feed = {
      path     = "/feed.xml";
      template = templates.feed.atom;
      # Bypassing the layout
      layout   = id;
      items    = take 10 posts.list;
    };

    /* 404 error page
    */
    e404 = {
      path     = "/404.html";
      template = templates.e404;
    };

    /* Posts lists
    */
    postsList = mkSplit {
      title        = "Posts";
      basePath     = "/posts/index";
      itemsPerPage = 3;
      template     = templates.posts-list;
      data         = posts.list;
    };

    /* Posts pages
    */
    posts = mkPageList {
      data        = data.posts;
      pathPrefix  = "/posts/";
      template    = templates.post.full;
    };

  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  # converting pages attribute set to a list
  pageList = lib.pagesToList {
    inherit pages;
    default = { layout = templates.layout; };
  };

  site = lib.mkSite {
    inherit pageList;
    # Loading custom files
    files = files ++ [ ./files ];
  };

}
