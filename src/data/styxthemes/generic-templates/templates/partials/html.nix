env:

let template = { templates, lib, conf, ... }:
  args:
  with lib;
  ''<html ${htmlAttr "lang" conf.theme.html.lang}>
  ${(templates.partials.head.default args)
  + (templates.partials.body         args)
  }</html>'';

in with env.lib; documentedTemplate {
  description = "Template responsible for generating the `html` tag, includes <<templates.partials.head.default>> and <<templates.partials.body>>.";
  inherit env template;
}
