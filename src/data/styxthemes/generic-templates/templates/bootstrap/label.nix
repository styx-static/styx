env:

let template = env:
  { content, type ? "default" }: ''<span class="label label-${type}">${content}</span>'';

in with env.lib; documentedTemplate {
  description = "Generate a bootstrap label.";
  arguments = {
    type = {
      description = "Type of the label.";
      type = ''"default" | "primary" | "success" | "info" | "warning" | "danger"'';
      default = "default";
    };
    content = {
      description = "Content of the label.";
      type = "String";
    };
  };
  examples = [ (mkExample {
    literalCode   = ''templates.bootstrap.label { content = "my label"; type = "primary"; }'';
    code =  with env; templates.bootstrap.label { content = "my label"; type = "primary"; };
  }) ];
  inherit env template;
}
