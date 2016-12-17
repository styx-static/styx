{ conf, lib, ... }:
with lib;
page:
let
  title = "${page.taxonomy}: ${page.term}";
  content =
''
  <h1>${title}</h1>
  <ul>
    ${mapTemplate (value: ''
      <li><a href="${conf.siteUrl}/${value.href}">${value.title}</a></li>
    '') page.values}
  </ul>
'';
in page // { inherit content title; }
