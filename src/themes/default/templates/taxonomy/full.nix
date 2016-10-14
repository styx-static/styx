{ conf, lib, ... }:
with lib;
page:
let content =
''
  <div class="container">
    <h1>${page.title}</h1>
    <ul>
    ${mapTemplate (prop:
    let term   = proplist.propKey   prop;
        values = proplist.propValue prop;
    in
    ''
      <li><a href="${conf.siteUrl}/${page.taxonomy}/${term}/">${term}</a>: ${toString (length values)}</li>
    '') (sortTerms page.terms)}
    </ul>
  </div>
'';
in page // { inherit content; }
