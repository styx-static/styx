{ conf, data, lib, ... }:
with lib;
''
  <div class="col-md-3">
    ${mapTemplate (plist:
      let taxonomy = propKey plist;
          terms    = sortTerms (propValue plist);
      in
      ''
        <p>${taxonomy}</p>
        <ul>
        ${mapTemplate (term: ''
          <li><a href="${conf.siteUrl}/${taxonomy}/${propKey term}/">${propKey term}</a> (${toString (valuesNb term)})</li>
        '') terms}
        </ul>
      '') data.taxonomies}
  </div>
''
