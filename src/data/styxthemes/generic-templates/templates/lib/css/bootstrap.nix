env:

let template = { conf, lib, templates, ... }:
  let cnf = conf.theme.lib.bootstrap;
  in
  lib.optionalString (cnf.enable == true)
    (templates.tag.link-css { href = "//maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/css/bootstrap.min.css"; });

in env.lib.documentedTemplate {
  inherit template env;
  description = "Template loading the bootstrap css library. Controlled by `conf.theme.lib.bootstrap.*` configuration options.";
}
