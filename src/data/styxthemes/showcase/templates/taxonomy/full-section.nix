{ conf, lib, templates, ... }:
with lib;
taxonomyData:
''
<section class="taxonomy">
${mapTemplate (plist:
  let taxonomy = proplist.propKey plist;
  in
  ''
    <header>${templates.tag.ilink {
      to      = mkTaxonomyPath taxonomy;
      content = taxonomy;
    }}</header>
    <ul class="terms">
    ${mapTemplate (t: ''
      <li>${templates.tag.ilink {
        to = t.path;
        content = t.term;
      }} (${toString t.count})</li>
    '') (templates.taxonomy.term-list plist)}
    </ul>
  '') taxonomyData}
</section>
''
