env: let
  template = env: icon: ''<i class="fa fa-${icon}" aria-hidden="true"></i>'';
in
  env.lib.template.documentedTemplate {
    description = "Generate a font-awesome icon markup from an icon code.";
    arguments = [
      {
        name = "icon";
        description = "The icon code to use without the leading `fa-`. See http://fontawesome.io/icons/ for available icons.";
        type = "String";
      }
    ];
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''templates.icon.font-awesome "code"'';
        code = with env; templates.icon.font-awesome "code";
      })
    ];
    inherit env template;
  }
