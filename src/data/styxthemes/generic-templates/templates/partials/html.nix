{ templates, lib, conf, ... }:
args:
with lib;
''<html ${htmlAttr "lang" conf.theme.html.lang}>
${(templates.partials.head.default args)
+ (templates.partials.body         args)
}</html>''
