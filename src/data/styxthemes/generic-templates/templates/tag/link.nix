env: let
  template = {lib, ...}: attrs: "<link ${lib.template.htmlAttrs attrs} />\n";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template generating a `link` tag.
    '';
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''templates.tag.link { href = "/feed.atom"; rel = "alternate"; type = "application/atom+xml"; }'';
        code = with env;
          templates.tag.link {
            href = "/feed.atom";
            rel = "alternate";
            type = "application/atom+xml";
          };
      })
    ];
    inherit env template;
  }
