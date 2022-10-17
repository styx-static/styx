env: let
  template = {lib, ...}: {src, ...} @ attrs: "<script ${lib.template.htmlAttrs attrs}></script>\n";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template generating a `script` tag.
    '';
    arguments = {
      src = {
        description = "Script source.";
        type = "String";
      };
    };
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.tag.script {
            src = "/script.js";
          }
        '';
        code = with env;
          templates.tag.script {
            src = "/script.js";
          };
      })
    ];
    inherit env template;
  }
