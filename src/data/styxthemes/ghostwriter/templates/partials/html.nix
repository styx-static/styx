{
  templates,
  lib,
  conf,
  ...
}: args:
with lib.lib; ''  <html ${lib.template.htmlAttr "lang" conf.theme.html.lang} prefix="og: http://ogp.me/ns#">
  ${
    (templates.partials.head.default args)
    + (templates.partials.body args)
  }</html>''
