env: let
  template = {
    lib,
    templates,
    ...
  }: {page}:
    with lib.lib;
      optionalString (page ? extraJS)
      (lib.template.mapTemplate templates.tag.script page.extraJS);
in
  env.lib.template.documentedTemplate {
    description = ''
      Template responsible for loading page specific javascript files. +
      To be used, the page should define an `extraJS` attribute containing a list of attribute sets that will be passed to `templates.tag.script`.
    '';
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          pages.index = {
            layout   = templates.layout;
            template = templates.pages.full;
            path     = "/index.html";
            extraJS = [ { src = "/index.js"; }  ];
          };
        '';
      })
    ];
    inherit env template;
  }
