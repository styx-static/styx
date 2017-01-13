/* This template automatically display breadcrumbs to a page that has a breadcrumbs attribute
*/
{ lib, conf, templates, ... }:
with lib;
page:
optionalString (page ? breadcrumbs) ''
<ol class="breadcrumb">
  ${mapTemplate (p: ''
    <li>${templates.tag.ilink { content = p.breadcrumbTitle or p.title; page = p;  }}</li>
  '') page.breadcrumbs}
  <li class="active">${page.breadcrumbTitle or page.title}</li>
</ol>
''
