env: let
  template = env: page: "";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template rendering the page post-contents, usually used to render the footer. Empty by default.
    '';
    inherit env template;
  }
