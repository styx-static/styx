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

    /* Menu using blocks
    */
    menu = let
      mkBlockSet = blocks:
        map (id:
          (lib.find { inherit id; } blocks) // { navbarClass = "page-scroll"; url = "/#${id}"; }
        );
    in
      (mkBlockSet pages.index.blocks [ "services" "portfolio" "about" "team" "contact" ])
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
        (banner            data.main-banner)
        (services          data.services)
        (portfolio (darken data.portfolio))
        (timeline          data.about)
        (team      (darken data.team))
        (clients           data.clients)
        (contact           data.contact) 
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
