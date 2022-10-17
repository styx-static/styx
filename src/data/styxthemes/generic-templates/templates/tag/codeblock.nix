env: let
  template = {lib, ...}: {content}: "<pre><code>${lib.template.escapeHTML content}</pre></code>";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template generating a code block, automatically escape HTML characters.
    '';
    arguments = {
      content = {
        description = "Codeblock content.";
        type = "String";
      };
    };
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.tag.codeblock {
            content = "<p>some html</p>";
          }
        '';
        code = with env;
          templates.tag.codeblock {
            content = "<p>some html</p>";
          };
      })
    ];
    inherit env template;
  }
