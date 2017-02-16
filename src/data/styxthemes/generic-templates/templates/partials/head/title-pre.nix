env:

let template = { templates, ... }:
  args: templates.partials.head.meta args;

in with env.lib; documentedTemplate {
  description = ''
    Template loading `head` tag contents before title. +
    Includes <<templates.partials.head.meta>>.
  '';
  inherit env template;
}
