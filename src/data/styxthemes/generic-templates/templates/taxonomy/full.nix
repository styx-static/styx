env:
let template = { lib, templates, ... }:
  with lib;
  normalTemplate(page: rec {
    title = page.title or page.taxonomy;
    content = 
    ''
      <h1>${title}</h1>
      <ul>
      ${mapTemplate (t: ''
        <li>${templates.tag.ilink {
          path = t.path;
          content = t.term;
        }} (${toString t.count})</li>''
      ) (templates.taxonomy.term-list page.taxonomyData)}
      </ul>
    '';
  });

in with env.lib; documentedTemplate {
  description = ''
    Template displaying a taxonomy information.
  '';
  arguments = {
    page = {
      description = "Taxonomy page generated with `mkTaxonomyPages` function.";
      type = "page";
    };
  };
  examples = [ (mkExample {
    literalCode = ''
      pages.taxonomies = mkTaxonomyPages {
        data             = data.taxonomies.posts;
        taxonomyTemplate = templates.taxonomy.full;
        termTemplate     = templates.taxonomy.term.full;
      };
    '';
  }) (mkExample {
    literalCode = ''
      templates.taxonomy.full (getProp "tags" (mkTaxonomyData {
        data = [
          { tags = [ "foo" "bar" ]; path = "/a.html"; }
          { tags = [ "foo" ];       path = "/b.html"; }
          { category = [ "baz" ];   path = "/c.html"; }
        ];
        taxonomies = [ "tags" "category" ];
      }))
    '';
    code = with env; (
      templates.taxonomy.full {
        taxonomy = "tags";
        taxonomyData = (getProp "tags" (mkTaxonomyData {
          data = [
            { tags = [ "foo" "bar" ]; path = "/a.html"; }
            { tags = [ "foo" ];       path = "/b.html"; }
            { category = [ "baz" ];   path = "/c.html"; }
          ];
          taxonomies = [ "tags" "category" ];
        }));

      }).content;
  }) ];
  inherit env template;
}
