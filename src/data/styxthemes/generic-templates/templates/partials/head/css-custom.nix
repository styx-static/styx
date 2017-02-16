env:

let template = env: page: "";

in with env.lib; documentedTemplate {
  description = ''
    Template to load custom css files, empty by default. Should be overridden to fit needs.
  '';
  inherit env template;
}
