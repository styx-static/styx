{ templates, ... }:
args:
  (templates.partials.head.feed args)
+ (templates.partials.head.css args)
+ (templates.partials.head.title-post-extra args)
