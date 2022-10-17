env: let
  template = {templates, ...}: attrs:
    templates.tag.link ({
        rel = "stylesheet";
        type = "text/css";
      }
      // attrs);
in
  env.lib.template.documentedTemplate {
    description = "Generate a `link` tag for a css file.";
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''templates.tag.link-css { href = "/css/style.css"; }'';
        code = with env; templates.tag.link-css {href = "/css/style.css";};
      })
    ];
    inherit env template;
  }
