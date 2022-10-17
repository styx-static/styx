env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib.lib; let
      cnf = conf.theme.lib.bootstrap;
    in
      optionalString cnf.enable
      (templates.tag.link-css {href = "//maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/css/bootstrap.min.css";});
in
  env.lib.template.documentedTemplate {
    inherit template env;
    description = "Template loading the bootstrap css library. Controlled by `conf.theme.lib.bootstrap.*` configuration options.";
  }
