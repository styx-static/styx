env:

let template = { lib, conf, ... }:
  { page, ... }:
  ''
  <title>${page.title}${lib.optionalString (lib.hasAttrByPath ["theme" "site" "title"] conf) " - ${conf.theme.site.title}"}</title>
  '';

in with env.lib; documentedTemplate {
  description = ''
    Template rendering the page `head` `title` tag.
  '';
  inherit env template;
}
