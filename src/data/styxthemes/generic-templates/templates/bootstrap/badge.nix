env:

let template = { lib, ... }:
  content: ''<span class="badge">${lib.toString content}</span>'';

in with env.lib; documentedTemplate {
  description = "Generate a bootstrap badge.";
  arguments = [
    { 
      name = "content";
      description = "Content of the badge.";
      type = "String";
    }
  ];
  examples = [ (mkExample {
    literalCode = ''templates.bootstrap.badge 42'';
    code = with env; templates.bootstrap.badge 42;
  }) ];
  inherit env template;
}
