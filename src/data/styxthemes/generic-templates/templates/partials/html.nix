env:

let template = { templates, lib, conf, html ? {}, ... }:
  args:
  with lib;
  let lang = 
    if html ? lang
    then html.lang
    else if hasAttrByPath [ "html" "lang" ] conf.theme
         then conf.theme.html.lang
         else "en";
  in
  ''<html ${htmlAttr "lang" lang}>
  ${(templates.partials.head.default args)
  + (templates.partials.body         args)
  }</html>'';

in with env.lib; documentedTemplate {
  description = "Template responsible for generating the `html` tag, includes <<templates.partials.head.default>> and <<templates.partials.body>>.";
  inherit env template;
}
