env:

let template = { conf, lib, templates,  ... }:
  let cnf = conf.theme.lib.bootstrap;
  in
  lib.optionalString (cnf.enable == true)
    (templates.tag.script {
      src = "//maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/js/bootstrap.min.js";
      crossorigin = "anonymous";
    });

in env.lib.documentedTemplate {
  description = "Template loading the bootstrap javascript library. Controlled by `conf.theme.lib.jquery.*` configuration options.";
  inherit env template;
}
