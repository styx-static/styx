{ conf, lib, ... }:
with lib;
taxonomyData:
''
  <section class="taxonomy">
  ${mapTemplate (plist:
    let taxonomy = proplist.propKey plist;
        terms    = sortTerms (proplist.propValue plist);
    in
    ''
      <header><a href="${conf.siteUrl}/${taxonomy}/">${taxonomy}</a></header>
      <ul class="terms">
      ${mapTemplate (term: ''
        <li><a href="${conf.siteUrl}/${taxonomy}/${proplist.propKey term}/">${proplist.propKey term}</a> (${toString (valuesNb term)})</li>
      '') terms}
      </ul>
    '') taxonomyData}
  </section>
''
