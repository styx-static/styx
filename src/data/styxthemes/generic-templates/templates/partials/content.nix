env:

let template = env:
  { page, ... }:
  ''
  ${page.content}
  '';

in with env.lib; documentedTemplate {
  description = ''
    Template rendering the page `content`.
  '';
  inherit env template;
}
