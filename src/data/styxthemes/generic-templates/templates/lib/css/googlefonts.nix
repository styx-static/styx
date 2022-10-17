env: let
  template = {
    lib,
    conf,
    templates,
    ...
  }:
    with lib.lib; let
      cnf = conf.theme.lib.googlefonts;
      fonts = concatStringsSep "|" (map (replaceStrings [" "] ["+"]) cnf);
    in
      optionalString (cnf != [])
      (templates.tag.link-css {href = "//fonts.googleapis.com/css?family=${fonts}";});
in
  env.lib.template.documentedTemplate {
    inherit template env;
    description = "Template loading google fonts fonts. Controlled by `conf.theme.lib.googlefonts.*` configuration options.";
  }
