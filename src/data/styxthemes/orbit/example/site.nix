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

  data = {
  };


/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = {
    index = {
      title    = "Home";
      path     = "/index.html";
      template = templates.block-page.full;
      layout   = templates.layout;
      blocks   = [
        (templates.blocks.summary conf.theme.summary)
        (templates.blocks.experiences conf.theme.experiences)
        (templates.blocks.projects conf.theme.projects)
        (templates.blocks.skills conf.theme.skills)
      ];
      sidebar-blocks = [
        (templates.blocks.profile conf.theme.profile)
        (templates.blocks.contact conf.theme.contact)
        (templates.blocks.education conf.theme.education)
        (templates.blocks.languages conf.theme.languages)
        (templates.blocks.interests conf.theme.interests)
      ];
    };
  };


/*-----------------------------------------------------------------------------
   Site rendering

-----------------------------------------------------------------------------*/

  site = lib.mkSite { inherit files;  pageList = [ pages.index ]; };

}
