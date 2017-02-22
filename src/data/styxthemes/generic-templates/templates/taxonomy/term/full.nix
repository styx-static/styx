env:

let template = { lib, templates, ... }:
  with lib;
  normalTemplate (page: rec {
    title = page.title or "${page.taxonomy}: ${page.term}";
    content = ''
      <h1>${title}</h1>
      <ul>
      ${mapTemplate (value: ''
        <li>${templates.tag.ilink {
          to = value;
        }}</li>'') page.values}
      </ul>
    '';
  });

in with env.lib; documentedTemplate {
  description = ''
    Template displaying a taxonomy term information.
  '';
  arguments = {
    page = {
      description = "Taxonomy term page generated with `mkTaxonomyPages` function.";
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
      templates.taxonomy.term.full {
        taxonomy = "tags";
        term = "foo";
        values = getValue "foo" (getValue "tags" (mkTaxonomyData {
          data = [
            { tags = [ "foo" "bar" ]; path = "/a.html"; title = "a"; }
            { tags = [ "foo" ];       path = "/b.html"; title = "b";}
            { category = [ "baz" ];   path = "/c.html"; title = "c";}
          ];
          taxonomies = [ "tags" "category" ];
        }));
      }
    '';
    code = with env; (
      templates.taxonomy.term.full {
        taxonomy = "tags";
        term = "foo";
        values = getValue "foo" (getValue "tags" (mkTaxonomyData {
          data = [
            { tags = [ "foo" "bar" ]; path = "/a.html"; title = "a"; }
            { tags = [ "foo" ];       path = "/b.html"; title = "b";}
            { category = [ "baz" ];   path = "/c.html"; title = "c";}
          ];
          taxonomies = [ "tags" "category" ];
        }));
      }).content;
  }) ];
  inherit env template;
}
