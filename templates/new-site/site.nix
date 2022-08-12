/*-----------------------------------------------------------------------------
   Destructured Context:

   lib: The styx lib; themes: The styx built-in themes

   You can also descructure into scope any package from nixpkgs
-----------------------------------------------------------------------------*/
{ lib, themes }:
let

  /*-----------------------------------------------------------------------------
     Setup
  
     This section setup required variables
  -----------------------------------------------------------------------------*/
  styx = lib.initStyx {
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
      #   themes.generic-templates
      # Or from a local path
      #   ./themes/my-theme
    ];

    # Environment propagated to templates
    env = {
      inherit data pages;
      # recursively propagate initialized lib, config & templates
      inherit (styx) lib conf templates;
    };
  };

  /*-----------------------------------------------------------------------------
     Data
  
     This section declares the data used by the site
     styx (in scope): docs lib decls env conf templates

     Note: unlike lib, styx.lib here is hydrated with styx.conf
  -----------------------------------------------------------------------------*/
  data = with styx; {
  };

  /*-----------------------------------------------------------------------------
     Pages
  
     This section declares the pages that will be generated
     styx (in scope): docs lib decls env conf templates

     Note: unlike lib, styx.lib here is hydrated with styx.conf
  -----------------------------------------------------------------------------*/
  pages = with styx; {
  };


in
/*-----------------------------------------------------------------------------
   Site

   Generating the site
-----------------------------------------------------------------------------*/
lib.mkSite {
  inherit (styx) files;
  # Converting the pages attribute set to a list
  pageList = lib.pagesToList {
    inherit pages;
    default.layout = styx.templates.layout;
  };
}
