/* Template to load the jquery javascript library

*/
{ conf, lib, templates, ... }:
let cnf = conf.theme.lib.jquery;
in
lib.optionalString (cnf.enable == true) 
  (templates.tag.script {
    src = "https://code.jquery.com/jquery-${cnf.version}.min.js";
    crossorigin = "anonymous";
  })
