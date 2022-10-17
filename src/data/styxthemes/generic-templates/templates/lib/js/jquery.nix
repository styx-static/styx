/*
Template to load the jquery javascript library
*/
env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib.lib; let
      cnf = conf.theme.lib.jquery;
    in
      optionalString (cnf.enable == true)
      (templates.tag.script {
        src = "//code.jquery.com/jquery-${cnf.version}.min.js";
        crossorigin = "anonymous";
      });
in
  env.lib.template.documentedTemplate {
    description = "Template loading the jQuery javascript library. Controlled by `conf.theme.lib.jquery.*` configuration options.";
    inherit template env;
  }
