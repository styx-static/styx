env:

let template = env: page: "";

in with env.lib; documentedTemplate {
  description = ''
    Template rendering the page pre-contents, usually used to render navigations. Empty by default.
  '';
  inherit env template;
}
