{ conf, lib, ... }:
with lib;
page:
let content =
''
  <div class="container">
    <h1>${page.title}</h1>
    <ul>
    </ul>
  </div>
'';
in page // { inherit content; }
    /*
    ${mapTemplate (p: ''
      <li><a href="${conf.siteUrl}/${p.href}">${p.title}</a></li>
    '') page.values}
    */
