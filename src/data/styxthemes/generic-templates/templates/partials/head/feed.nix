env: let
  template = {
    lib,
    pages,
    templates,
    ...
  }: args:
    with lib.lib;
      optionalString (pages ? feed)
      (templates.tag.link-atom {
        href = templates.url pages.feed;
      });
in
  env.lib.template.documentedTemplate {
    description = ''
      Template that will automaticly load `pages.feed` if defined as an atom feed.
    '';
    inherit env template;
  }
