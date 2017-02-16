env:

let template = env: ''<a class="navbar-brand" href="#">Brand</a>'';

in with env.lib; documentedTemplate {
  description = ''
    Template used by default as the navbar brand, can be overriden to fit needs.
  '';
  inherit env template;
}
