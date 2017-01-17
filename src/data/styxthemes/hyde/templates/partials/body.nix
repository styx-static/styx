{ templates, lib, conf, ... }:
args:
with lib;
let 
  class = htmlAttr "class" (
       (optional (conf.theme.colorScheme != null) "theme-base-${conf.theme.colorScheme}")
    ++ (optional (conf.theme.layout.reverse) "layout-reverse")
  );
in
''
<body ${class}>
${(templates.partials.content-pre  args)
+ (templates.partials.content      args)
+ (templates.partials.content-post args)
+ (templates.partials.js args)
}</body>
''
