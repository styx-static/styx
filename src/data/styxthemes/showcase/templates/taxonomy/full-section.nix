{
  conf,
  lib,
  templates,
  ...
}:
with lib.lib;
  taxonomyData: ''
    <section class="taxonomy">
    ${lib.template.mapTemplate (plist: let
        taxonomy = lib.proplist.propKey plist;
      in ''
        <header>${templates.tag.ilink {
          to = lib.pages.mkTaxonomyPath taxonomy;
          content = taxonomy;
        }}</header>
        <ul class="terms">
        ${lib.template.mapTemplate (t: ''
          <li>${templates.tag.ilink {
            to = t.path;
            content = t.term;
          }} (${toString t.count})</li>
        '') (templates.taxonomy.term-list plist)}
        </ul>
      '')
      taxonomyData}
    </section>
  ''
