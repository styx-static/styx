env:

let template = { lib, conf, templates, ... }:
  with lib;
  let cnf = conf.theme.lib.googlefonts;
      fonts = concatStringsSep "|" (map (replaceStrings [" "] ["+"]) cnf);
  in
  lib.optionalString (cnf != [])
    (templates.tag.link-css { href = "https://fonts.googleapis.com/css?family=${fonts}"; });

in env.lib.documentedTemplate {
  inherit template env;
  description = "Template loading google fonts fonts. Controlled by `conf.theme.lib.googlefonts.*` configuration options.";
}
