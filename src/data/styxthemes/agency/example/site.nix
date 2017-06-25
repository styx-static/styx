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

    /* Menu using blocks
    */
    menu = let
      indexBlocks = pages.index.blocks;
      bItems = map (n:
        let block = find { id = n; } indexBlocks;
        in block // { navbarClass = "page-scroll"; url = "/#${block.id}"; }
      ) [ "services" "portfolio" "about" "team" "contact" ];
    in bItems
    ++ [
      { title = "Styx"; url = "https://styx-static.github.io/styx-site/"; }
    ];

  } // (lib.loadDir { dir = ./data; inherit env; asAttrs = true; });


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = rec {
    index = {
      title    = "Home";
      path     = "/index.html";
      template = templates.block-page.full;
      layout   = templates.layout;
      blocks   = let
        darken = d: d // { class = "bg-light-gray"; };
      in with templates.blocks; [
        (banner data.main-banner)
        (services data.services)
        (portfolio (darken data.portfolio))
        (timeline data.about)
        (team (darken data.team))
        (clients data.clients)
        (contact data.contact) 
      ];
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

  site = lib.mkSite { inherit files pageList; };

}
