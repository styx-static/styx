/*
generic template for a tag

templates.tag.generic { tag = "div"; content = "hello world" }
*/
env: let
  template = {lib, ...}: {
    tag,
    content,
    ...
  } @ args:
    with lib.lib; let
      attrs = lib.template.htmlAttrs (removeAttrs args ["tag" "content"]);
    in "<${tag}${optionalString (attrs != "") " ${attrs}"}>${content}</${tag}>";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template generating a generic html tag.
    '';
    arguments = {
      tag = {
        description = "HTML tag to render.";
        type = "String";
      };
      content = {
        decription = "content of the tag.";
        type = "String";
      };
    };
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.tag.generic { tag = "div"; content = "hello world!"; class = "foo"; }
        '';
        code = with env;
          templates.tag.generic {
            tag = "div";
            content = "hello world!";
            class = "foo";
          };
      })
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.tag.generic {
            tag = "div";
            content = templates.tag.generic { tag = "p"; content = "hello world!"; };
          }
        '';
        code = with env;
          templates.tag.generic {
            tag = "div";
            content = templates.tag.generic {
              tag = "p";
              content = "hello world!";
            };
          };
      })
    ];
    notes = ''
      Any extra argument passed will be added as tag attributes.
    '';
    inherit env template;
  }
