{ lib, conf, ... }:
with lib;
page:
  optionalString (page ? breadcrumbs) ''
  <ol class="breadcrumb">
    ${mapTemplate (p: ''
      <li><a href="${conf.siteUrl}/${p.href}">${p.breadcrumbTitle or p.title}</a></li>
    '') page.breadcrumbs}
    <li class="active">${page.title}</li>
  </ol>
  ''
