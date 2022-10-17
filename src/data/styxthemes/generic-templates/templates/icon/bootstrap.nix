env: let
  template = env: icon: ''<span class="glyphicon glyphicon-${icon}" aria-hidden="true"></span>'';
in
  with env.lib.template;
    documentedTemplate {
      description = "Generate a bootstrap glyphicon markup from a glyphicon code.";
      arguments = [
        {
          name = "icon";
          description = "The icon code to use without the leading `glyphicon-`. See http://getbootstrap.com/components/#glyphicons for available icons.";
          type = "String";
        }
      ];
      examples = [
        (env.lib.utils.mkExample {
          literalCode = ''templates.icon.bootstrap "picture"'';
          code = with env; templates.icon.bootstrap "picture";
        })
      ];
      inherit env template;
    }
