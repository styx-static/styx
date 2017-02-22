env:

let template = { conf, templates, ... }:
  { to
  , content ? ""
  , ...
  }@args:
  templates.tag.generic ((removeAttrs args [ "path" "to" ]) // {
    tag = "a";
    href = templates.url to;
    content = if content != ""
              then content
              else to.title; 
  });

in with env.lib; documentedTemplate {
  description = "Generate an **i**nternal **link**.";
  arguments = {
    to = {
      description = "Link target, can be a string or a page.";
      type = "String | Page";
    };
  };
  examples = [
  (mkExample {
    literalCode  = ''templates.tag.ilink { to = { path = "/about.html"; }; content = "about"; }'';
    code = with env; templates.tag.ilink { to = { path = "/about.html"; }; content = "about"; };
  })
  (mkExample {
    literalCode  = ''templates.tag.ilink { to = "/files/manual.pdf"; content = "Download manual"; class = "download"; }'';
    code = with env; templates.tag.ilink { to = "/files/manual.pdf"; content = "Download manual"; class = "download"; };
  }) ];
  notes = ''
    * Any extra argument passed will be added as tag attributes.
  '';
  inherit env template;
}
