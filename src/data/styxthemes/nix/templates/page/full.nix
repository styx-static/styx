{
  lib,
  templates,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (page: ''
    ${optionalString (page ? title) "<h1>${page.title}</h1>"}
    ${page.content}

    ${optionalString (page ? pages) (templates.bootstrap.pagination {inherit (page) pages index;})}
  '')
