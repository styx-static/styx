{ conf, lib, ... }:
with lib;
page:
let content =
''
  <div class="container">
    <h1>${page.taxonomy}: ${page.title}</h1>
    <ul>
      ${mapTemplate (value: ''
        <li><a href="${conf.siteUrl}/${value.href}">${value.title}</li>
      '') page.values}
    </ul>
  </div>
'';
in page // { inherit content; }
