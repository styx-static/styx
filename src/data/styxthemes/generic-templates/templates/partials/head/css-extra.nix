/* This template allow to add custom css file per page attribute set.
   If a page defines a `extraCSS` attribute, its contents will be loaded here

   extraCSS should be a list of attribute set in the followong format:

     [ { href = "..."; } ]

   Any extra attribute to the list will be added as a html attribute to the link tag
*/
env:

let template = { lib, templates, ... }:
  { page }:
  with lib;
  optionalString (page ? extraCSS)
    (mapTemplate templates.tag.link-css page.extraCSS);

in with env.lib; documentedTemplate {
  description = ''
    Template responsible for loading page specific css files. +
    To be used, the Page should define an `extraCSS` attribute containing a list of attribute sets.
  '';
  examples = [ (mkExample {
    literalCode = ''
      pages.index = {
        layout   = templates.layout;
        template = templates.pages.full;
        path     = "/index.html";
        extraCSS = [ { href = "/css/index.css"; } ];
      };
    '';
  }) ];
  inherit env template;
}
