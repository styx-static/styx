env: let
  template = {templates, ...}: page:
    templates.partials.doctype
    + templates.partials.html {inherit page;};
in
  env.lib.template.documentedTemplate {
    description = ''
      Generic layout template, includes <<templates.partials.doctype>> and <<templates.partials.html>>.
    '';
    inherit env template;
  }
