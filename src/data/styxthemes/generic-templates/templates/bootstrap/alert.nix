env:

let template = env:
  { type ? "info"
  , content }:
  ''
  <div class="alert alert-${type}" role="alert">
  ${content}
  </div>'';

in with env.lib; documentedTemplate {
  description = "Generate a bootstrap alert.";
  arguments = {
    type = {
      description = "Type of the alert.";
      type = ''"success" | "info" | "warning" | "danger"'';
    };
    content = {
      description = "Content of the alert.";
      type = "String";
    };
  };
  examples = [ (mkExample {
    literalCode   = ''templates.bootstrap.alert { type = "success"; content = "alert"; }'';
    code =  with env; templates.bootstrap.alert { type = "success"; content = "alert"; }; 
  }) ];
  inherit env template;
}
