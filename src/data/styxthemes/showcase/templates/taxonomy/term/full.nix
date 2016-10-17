{ conf, lib, ... }:
with lib;
page:
let content =
''
  <h1>${page.taxonomy}: ${page.title}</h1>
  <ul>
    ${mapTemplate (value: ''
      <li><a href="${conf.siteUrl}/${value.href}">${value.title}</a></li>
    '') page.values}
  </ul>
'';
in page // { inherit content; }
