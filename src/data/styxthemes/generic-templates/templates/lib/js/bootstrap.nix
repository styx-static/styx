/* Template to load the bootstrap javascript library

*/
{ conf, lib, templates,  ... }:
let cnf = conf.theme.lib.bootstrap;
in
lib.optionalString (cnf.enable == true) 
  (templates.tag.script {
    src = "https://maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/js/bootstrap.min.js";
    crossorigin = "anonymous";
  })
