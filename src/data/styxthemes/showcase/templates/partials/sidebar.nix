{ conf, data, lib, ... }:
with lib;
''
  <div class="col-md-3">
    ${mapTemplate (plist:
      let taxonomy = proplist.propKey plist;
          terms    = sortTerms (proplist.propValue plist);
      in
      ''
        <p>${taxonomy}</p>
        <ul>
        ${mapTemplate (term: ''
          <li><a href="${conf.siteUrl}/${taxonomy}/${proplist.propKey term}/">${proplist.propKey term}</a> (${toString (valuesNb term)})</li>
        '') terms}
        </ul>
      '') data.taxonomies}
  </div>
''
