env:

let template = { lib, ... }: { content }: "<pre><code>${lib.escapeHTML content}</pre></code>";

in with env.lib; documentedTemplate {
  description = ''
    Template generating a code block, automatically escape HTML characters.
  '';
  arguments = {
   content = {
     description = "Codeblock content.";
     type = "String";
   };
  };
  examples = [ (mkExample {
    literalCode = ''
      templates.tag.codeblock {
        content = "<p>some html</p>";
      }
    '';
    code = with env;
      templates.tag.codeblock {
        content = "<p>some html</p>";
      }
    ;
  }) ];
  inherit env template;
}
