/* Template to load the jquery javascript library

*/
env:

let template = { conf, lib, templates, ... }:
  let cnf = conf.theme.lib.jquery;
  in
  lib.optionalString (cnf.enable == true)
    (templates.tag.script {
      src = "https://code.jquery.com/jquery-${cnf.version}.min.js";
     crossorigin = "anonymous";
    });

in env.lib.documentedTemplate {
  description = "Template loading the jQuery javascript library. Controlled by `conf.theme.lib.jquery.*` configuration options.";
  inherit template env;
}
