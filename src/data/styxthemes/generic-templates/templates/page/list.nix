env: let
  template = {
    templates,
    lib,
    ...
  }:
    lib.template.normalTemplate (
      page: "<li>${templates.tag.ilink {to = page;}}</li>"
    );
in
  env.lib.template.documentedTemplate {
    description = "Normal template for rendering a page as a list entry (`li` tag).";

    inherit env template;
  }
