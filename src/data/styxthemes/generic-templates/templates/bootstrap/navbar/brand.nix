env: let
  template = env: ''<a class="navbar-brand" href="#">Brand</a>'';
in
  env.lib.template.documentedTemplate {
    description = ''
      Template used by default as the navbar brand, can be overriden to fit needs.
    '';
    inherit env template;
  }
