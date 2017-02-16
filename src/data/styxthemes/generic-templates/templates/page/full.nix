env:

let template = { lib, templates, ... }:
  lib.normalTemplate (page: ''
    <div>
    ${lib.optionalString (page ? title) "<h1>${page.title}</h1>"}
    ${page.content}

    ${lib.optionalString (page ? pages) (templates.bootstrap.pagination { inherit (page) pages index; })}
    </div>
  '');

in with env.lib; documentedTemplate {
  description = "Normal template for rendering a page.";

  inherit env template;
}
