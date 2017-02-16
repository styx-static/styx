env:

let template = { conf, templates, ... }:
  { path ? null
  , page ? null
  , content
  , ...
  }@args:
  templates.tag.generic ((removeAttrs args [ "path" "page" ]) // {
    tag = "a";
    href = if path != null
           then templates.url path
           else templates.url page;
  });

in with env.lib; documentedTemplate {
  description = "Generate an **i**nternal **link**.";
  arguments = {
    path = {
      description = "Path of the link to generate.";
      type = "String";
      default = null;
    };
    page = {
      description = "Page to link.";
      type = "String";
      default = null;
    };
  };
  examples = [
  (mkExample {
    literalCode  = ''templates.tag.ilink { page = { path = "/about.html"; }; content = "about"; }'';
    code = with env; templates.tag.ilink { page = { path = "/about.html"; }; content = "about"; };
  })
  (mkExample {
    literalCode  = ''templates.tag.ilink { path = "/files/manual.pdf"; content = "Download manual"; class = "download"; }'';
    code = with env; templates.tag.ilink { path = "/files/manual.pdf"; content = "Download manual"; class = "download"; };
  }) ];
  notes = ''
    * `page` or `path` must be passed.
    * Any extra argument passed will be added as tag attributes.
  '';
  inherit env template;
}
