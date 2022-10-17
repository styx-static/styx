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
      (templates.tag.script {
        src = "//maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/js/bootstrap.min.js";
        crossorigin = "anonymous";
      });
in
  env.lib.template.documentedTemplate {
    description = "Template loading the bootstrap javascript library. Controlled by `conf.theme.lib.jquery.*` configuration options.";
    inherit env template;
  }
