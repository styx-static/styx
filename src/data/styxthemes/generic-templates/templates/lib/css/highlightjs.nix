env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib.lib; let
      cnf = conf.theme.lib.highlightjs;
    in
      optionalString cnf.enable
      (templates.tag.link-css {href = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/styles/${cnf.style}.min.css";});
in
  env.lib.template.documentedTemplate {
    inherit template env;
    description = "Template loading highlightjs required css. Controlled by `conf.theme.lib.highlightjs.*` configuration options.";
  }
