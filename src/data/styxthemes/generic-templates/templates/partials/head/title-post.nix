env:

let template = { templates, ... }:
  args:
    (templates.partials.head.feed args)
  + (templates.partials.head.css args)
  + (templates.partials.head.title-post-extra args);

in with env.lib; documentedTemplate {
  description = ''
    Template loading `head` tag contents after title. +
    Includes <<templates.partials.head.feed>>, <<templates.partials.head.css>> and <<templates.partials.head.title-post-extra>>.
  '';
  inherit env template;
}
