/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ styx
, extraConf ? {}
}@args:

rec {

  /* Importing styx library
  */
  styxLib = import styx.lib styx;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* Importing styx themes from styx
  */
  styx-themes = import styx.themes;

  /* list the themes to load, paths or packages can be used
     items at the end of the list have higher priority
  */
  themes = [ 
    styx-themes.generic-templates
    ../.
  ];

  /* Loading the themes data
  */
  themesData = styxLib.themes.load {
    inherit styxLib themes;
    extraEnv  = { inherit data pages; };
    extraConf = [ ./conf.nix extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates env;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = with lib; {
    # loading a single page
    about  = loadFile { file = "${styx}/share/styx/scaffold/sample-data/pages/about.md"; inherit env; };

    # loading a list of contents
    posts  = sortBy "date" "dsc" (loadDir { dir = "${styx}/share/styx/scaffold/sample-data/posts"; inherit env; });

    menu = [
      (head pages.index)
      pages.about
    ];

    # Create an author data
    author = {
      name = "John Doe";
      # It is possible to set a link to the author
      # url = "http://john-doe.org/";
    };
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = with lib; rec {
    index = mkSplit {
      title        = "Home";
      basePath     = "/index";
      itemsPerPage = conf.theme.itemsPerPage;
      template     = templates.index;
      data         = posts.list;
    };
    
    /* Feed page
    */
    feed = {
      path     = "/feed.xml";
      template = templates.feed.atom;
      # Bypassing the layout
      layout   = id;
      items    = take 10 posts.list;
    };

    about = {
      path     = "/about.html";
      template = templates.page.full;
    } // data.about;

    posts = mkPageList {
      data        = data.posts;
      pathPrefix  = "/posts/";
      template    = templates.post.full;
      # Attach the author to every blog post
      author      = data.author;
    };
  };


/*-----------------------------------------------------------------------------
   Site

-----------------------------------------------------------------------------*/

  /* Converting the pages attribute set to a list
  */
  pageList = lib.pagesToList {
    inherit pages;
    default = { layout = templates.layout; };
  };

  /* Generating the site
  */
  site =  (lib.mkSite { inherit files pageList; });

}
