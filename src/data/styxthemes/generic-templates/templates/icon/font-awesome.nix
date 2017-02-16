env:

let template = env: icon: ''<i class="fa fa-${icon}" aria-hidden="true"></i>'';

in with env.lib; documentedTemplate {
  description = "Generate a font-awesome icon markup from an icon code.";
  arguments = [
    {
      name = "icon";
      description = "The icon code to use without the leading `fa-`. See http://fontawesome.io/icons/ for available icons.";
      type = "String";
    }
  ];
  examples = [ (mkExample {
    literalCode  = ''templates.icon.font-awesome "code"'';
    code = with env; templates.icon.font-awesome "code";
  }) ];
  inherit env template;
}
