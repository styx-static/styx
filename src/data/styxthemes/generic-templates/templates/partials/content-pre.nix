env: let
  template = env: page: "";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template rendering the page pre-contents, usually used to render navigations. Empty by default.
    '';
    inherit env template;
  }
