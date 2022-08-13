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
