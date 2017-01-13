{ lib, ... }:
lib.normalTemplate (page:
  ''
  <div>
  ${lib.optionalString (page ? title) "<h1>${page.title}</h1>"}
  ${page.content}
  </div>
  ''
)
