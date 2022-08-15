/*-----------------------------------------------------------------------------
   Destructured Context:

   styxlib: The styx lib; styxthemes: The styx built-in themes; nixpgks: The Nix Package Collection

   Source:
   styxlib:    https://github.com/styx-static/styx/tree/master/renderes/styxlib.nix
   styxthemes: https://github.com/styx-static/styx/tree/master/data/styxthemes.nix

   You can also descructure into scope any package from nixpkgs
-----------------------------------------------------------------------------*/
{ styxlib, styxthemes, nixpkgs }:
let

  /*-----------------------------------------------------------------------------
     Setup
  
     This section setup required variables
  -----------------------------------------------------------------------------*/
  loaded = styxlib.themes.load {
    # Used configuration
    config = {
      /* URL of the site, must be set to the url of the domain the site will be deployed.
         Should not end with a '/'.
      */
      siteUrl = "http://yourdomain.com";
    
      /* Theme specific settings
         it is possible to override any of the used themes configuration in this set.
      */
      theme = {
      };
    }

    # Loaded themes
    themes = [
      # Declare the used themes here, from a package:
      #   styxthemes.generic-templates
      # Or from a local path
      #   ./themes/my-theme
    ];

    # Environment propagated to templates
    env = {
      inherit data pages;
      # recursively propagate initialized (hydrated) styxlib, conf & templates
      inherit (loaded) styxlib conf templates;
    };
  };

  /*-----------------------------------------------------------------------------
     Data
  
     This section declares the data used by the site
     loaded (in scope): docs lib decls env conf templates

     Note: unlike styxlib, loaded.styxlib is hydrated with evaled data
  -----------------------------------------------------------------------------*/
  data = with loaded; {
  };

  /*-----------------------------------------------------------------------------
     Pages
  
     This section declares the pages that will be generated
     loaded (in scope): docs lib decls env conf templates

     Note: unlike styxlib, loaded.styxlib is hydrated with evaled data
  -----------------------------------------------------------------------------*/
  pages = with loaded; {
  };


in
/*-----------------------------------------------------------------------------
   Site

   Generating the site
-----------------------------------------------------------------------------*/
styxlib.mkSite {
  inherit (loaded) files;
  # Converting the pages attribute set to a list
  pageList = styxlib.pagesToList {
    inherit pages;
    default.layout = loaded.templates.layout;
  };
}
