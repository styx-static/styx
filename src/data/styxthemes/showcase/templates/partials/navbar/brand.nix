{ conf, lib, ... }:
  with lib;
  ''
  <a class="navbar-brand" href="${conf.siteUrl}">
    ${attrByPath [ "theme" "navbar" "brand" ] conf.theme.site.title conf}
  </a>
  ''
