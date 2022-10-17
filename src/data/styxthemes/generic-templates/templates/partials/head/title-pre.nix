env: let
  template = {templates, ...}: templates.partials.head.meta;
in
  env.lib.template.documentedTemplate {
    description = ''
      Template loading `head` tag contents before title. +
      Includes <<templates.partials.head.meta>>.
    '';
    inherit env template;
  }
