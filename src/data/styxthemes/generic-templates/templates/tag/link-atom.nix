env: let
  template = {templates, ...}: attrs:
    templates.tag.link ({
        rel = "alternate";
        type = "application/atom+xml";
      }
      // attrs);
in
  env.lib.template.documentedTemplate {
    description = "Generate a `link` tag for an atom feed.";
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''templates.tag.link-atom { href = "/feed.atom"; }'';
        code = with env; templates.tag.link-atom {href = "/feed.atom";};
      })
    ];
    inherit env template;
  }
