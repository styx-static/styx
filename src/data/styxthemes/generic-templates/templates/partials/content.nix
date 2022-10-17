env: let
  template = env: {page, ...}: ''
    ${page.content}
  '';
in
  env.lib.template.documentedTemplate {
    description = ''
      Template rendering the page `content`.
    '';
    inherit env template;
  }
