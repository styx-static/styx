{ templates, ... }:
args:
  templates.lib.css.bootstrap
+ templates.lib.css.font-awesome
+ (templates.partials.head.css-custom args)
+ (templates.partials.head.css-extra  args)
