env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib.lib; let
      cnf = conf.theme.lib.font-awesome;
    in
      optionalString cnf.enable
      (templates.tag.link-css {href = "//maxcdn.bootstrapcdn.com/font-awesome/${cnf.version}/css/font-awesome.min.css";});
in
  env.lib.template.documentedTemplate {
    inherit template env;
    description = "Template loading font-awesome css library. Controlled by `conf.theme.lib.font-awesome.*` configuration options.";
  }
