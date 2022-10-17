env: let
  template = env: page: "";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template to add custom extra content in `head`. Empty by default, should be overriden to fit needs.
    '';
    inherit env template;
  }
