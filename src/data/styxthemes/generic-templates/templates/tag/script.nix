env:

let template = { lib, ... }: { src, ... }@attrs: "<script ${lib.htmlAttrs attrs}></script>\n";

in with env.lib; documentedTemplate {
  description = ''
    Template generating a `script` tag.
  '';
  arguments = {
    src = {
      description = "Script source.";
      type = "String";
    };
  };
  examples = [ (mkExample {
    literalCode = ''
      templates.tag.script {
        src = "/script.js";
      }
    '';
    code = with env;
      templates.tag.script {
        src = "/script.js";
      }
    ;
  }) ];
  inherit env template;
}

