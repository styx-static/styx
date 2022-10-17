env: let
  template = {lib, ...}:
    with lib.lib;
      {
        content,
        extraClasses ? [],
        align ? null,
        ...
      }: let
        alignClass = optional (align == "right" || align == "left") "navbar-${align}";
        class = lib.template.htmlAttr "class" (["navbar-text"] ++ alignClass ++ extraClasses);
      in ''
        <p ${class}>${content}</p>
      '';
in
  env.lib.template.documentedTemplate {
    description = "Template to generate a navbar text. Meant to be used in `bootstrap.navbar.default` `content` parameter.";
    arguments = {
      content = {
        description = "Text content.";
        type = "String";
      };
      align = {
        description = "Alignment of the text.";
        type = ''"right", "left" or null'';
        default = null;
      };
      extraClasses = {
        description = "Extra classes to add to the text.";
        default = [];
        type = "[ String ]";
      };
    };
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.bootstrap.navbar.text {
            content = "Hello world!";
            align = "right";
          }
        '';
        code = with env;
          templates.bootstrap.navbar.text {
            content = "Hello world!";
            align = "right";
          };
      })
    ];
    inherit template env;
  }
