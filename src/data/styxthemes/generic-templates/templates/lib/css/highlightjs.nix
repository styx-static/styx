env:

let template = { conf, lib, templates, ... }:
  let cnf = conf.theme.lib.highlightjs;
  in
  lib.optionalString (cnf.enable == true) 
    (templates.tag.link-css { href = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/styles/${cnf.style}.min.css"; });

in env.lib.documentedTemplate {
  inherit template env;
  description = "Template loading highlightjs required css. Controlled by `conf.theme.lib.highlightjs.*` configuration options.";
}
