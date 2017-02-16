env:

let template = { lib, templates, ... }:
  { page }:
  with lib;
  optionalString (page ? extraJS)
    (mapTemplate templates.tag.script page.extraJS);

in with env.lib; documentedTemplate {
  description = ''
    Template responsible for loading page specific javascript files. +
    To be used, the Page should define an `extraJS` attribute containing a list of attribute sets.
  '';
  examples = [ (mkExample {
    literalCode = ''
      pages.index = {
        layout   = templates.layout;
        template = templates.pages.full;
        path     = "/index.html";
        extraJS = [ { src = "/index.js"; crossorigin = "anonymous"; }  ];
      };
    '';
  }) ];
  inherit env template;
}
