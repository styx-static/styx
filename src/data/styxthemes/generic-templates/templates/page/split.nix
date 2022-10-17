env: let
  template = {
    templates,
    lib,
    ...
  }:
    with lib.lib;
      lib.template.normalTemplate (page: ''
        ${optionalString (page ? title) "<h1>${page.title}</h1>"}

        ${optionalString (length page.items > 0) ''
          <ul>
          ${lib.template.mapTemplate templates.page.list page.items}
          </ul>''}

        ${templates.bootstrap.pagination {inherit (page) pages index;}}
      '');
in
  env.lib.template.documentedTemplate {
    description = "Normal template for rendering splitted pages.";

    inherit env template;
  }
