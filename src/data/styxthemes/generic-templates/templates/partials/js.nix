{ templates, ... }:
args:
  templates.lib.js.jquery
+ templates.lib.js.bootstrap
+ (templates.partials.js-custom args)
+ (templates.partials.js-extra  args)
