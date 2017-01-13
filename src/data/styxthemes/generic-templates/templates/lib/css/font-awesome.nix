/* Template to load the bootstrap css library

*/
{ conf, lib, templates, ... }:
let cnf = conf.theme.lib.font-awesome;
in

lib.optionalString (cnf.enable == true) 
  (templates.tag.link-css { href = "https://maxcdn.bootstrapcdn.com/font-awesome/${cnf.version}/css/font-awesome.min.css"; })
