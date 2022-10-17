env: let
  template = {
    lib,
    templates,
    ...
  }:
    with lib.lib;
      lib.template.normalTemplate (page: ''
        <div>
        ${optionalString (page ? title) "<h1>${page.title}</h1>"}
        ${page.content}

        ${optionalString (page ? pages) (templates.bootstrap.pagination {inherit (page) pages index;})}
        </div>
      '');
in
  env.lib.template.documentedTemplate {
    description = "Normal template for rendering a page.";

    inherit env template;
  }
