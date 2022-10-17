env: let
  template = {
    lib,
    conf,
    ...
  }:
    with lib.lib;
      {page, ...}: ''
        <title>${page.title}${optionalString (hasAttrByPath ["theme" "site" "title"] conf) " - ${conf.theme.site.title}"}</title>
      '';
in
  env.lib.template.documentedTemplate {
    description = ''
      Template rendering the page `head` `title` tag.
    '';
    inherit env template;
  }
