env:

let template = { lib, ... }:
  { content
  , extraClasses ? []
  , align ? null
  , ... }:
  let
    alignClass = lib.optional (align == "right" || align == "left") "navbar-${align}";
    class = lib.htmlAttr "class" ([ "navbar-text" ] ++ alignClass ++ extraClasses);
  in
  ''
  <p ${class}>${content}</p>
  '';

in with env.lib; documentedTemplate {
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
  examples = [ (mkExample {
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
      }
    ;
  })];
  inherit template env;
}
