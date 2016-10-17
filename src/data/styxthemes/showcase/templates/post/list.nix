{ conf, lib, ... }:
with lib;
page:
let
  draftIcon = optionalString (attrByPath ["isDraft"] false page) "<span class=\"glyphicon glyphicon-file\"></span> ";
in
  ''
    <li>
      <a href="${conf.siteUrl}/${page.href}">${draftIcon}${page.title}</a>
    </li>
  ''
