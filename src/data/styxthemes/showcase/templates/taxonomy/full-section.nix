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
      path = templates.taxonomy.path taxonomy;
      content = taxonomy;
    }}</header>
    <ul class="terms">
    ${mapTemplate (t: ''
      <li>${templates.tag.ilink {
        path = t.path;
        content = t.term;
      }} (${toString t.number})</li>
    '') (templates.taxonomy.term-list plist)}
    </ul>
  '') taxonomyData}
</section>
''
