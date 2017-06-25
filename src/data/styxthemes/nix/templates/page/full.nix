{ lib, templates, ... }:
lib.normalTemplate (page: ''
  ${lib.optionalString (page ? title) "<h1>${page.title}</h1>"}
  ${page.content}

  ${lib.optionalString (page ? pages) (templates.bootstrap.pagination { inherit (page) pages index; })}
'')
