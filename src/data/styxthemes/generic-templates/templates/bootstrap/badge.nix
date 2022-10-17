env: let
  template = {lib, ...}: with lib.lib; content: ''<span class="badge">${toString content}</span>'';
in
  env.lib.template.documentedTemplate {
    description = "Generate a bootstrap badge.";
    arguments = [
      {
        name = "content";
        description = "Content of the badge.";
        type = "String";
      }
    ];
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''templates.bootstrap.badge 42'';
        code = with env; templates.bootstrap.badge 42;
      })
    ];
    inherit env template;
  }
