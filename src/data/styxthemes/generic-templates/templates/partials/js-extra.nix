env:

let template = { lib, templates, ... }:
  { page }:
  with lib;
  optionalString (page ? extraJS)
    (mapTemplate templates.tag.script page.extraJS);

in with env.lib; documentedTemplate {
  description = ''
    Template responsible for loading page specific javascript files. +
    To be used, the page should define an `extraJS` attribute containing a list of attribute sets that will be passed to `templates.tag.script`.
  '';
  examples = [ (mkExample {
    literalCode = ''
      pages.index = {
        layout   = templates.layout;
        template = templates.pages.full;
        path     = "/index.html";
        extraJS = [ { src = "/index.js"; }  ];
      };
    '';
  }) ];
  inherit env template;
}
