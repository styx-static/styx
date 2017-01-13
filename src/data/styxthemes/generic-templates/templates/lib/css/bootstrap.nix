/* Template to load the bootstrap css library

*/
{ conf, lib, templates, ... }:
let cnf = conf.theme.lib.bootstrap;
in

lib.optionalString (cnf.enable == true) 
  (templates.tag.link-css { href = "https://maxcdn.bootstrapcdn.com/bootstrap/${cnf.version}/css/bootstrap.min.css"; })
