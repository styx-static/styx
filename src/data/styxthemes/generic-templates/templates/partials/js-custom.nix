env: let
  template = env: page: "";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template to load custom javascript files, empty by default. Should be overridden to fit needs.
    '';
    inherit env template;
  }
