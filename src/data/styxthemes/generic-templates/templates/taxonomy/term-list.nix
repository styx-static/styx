env: let
  template = {
    templates,
    lib,
    ...
  }:
    with lib.lib;
      taxonomyData: let
        taxonomy = lib.proplist.propKey taxonomyData;
        terms = lib.proplist.propValue taxonomyData;
      in
        map (prop: let
          term = lib.proplist.propKey prop;
          values = lib.proplist.propValue prop;
        in {
          path = lib.pages.mkTaxonomyTermPath taxonomy term;
          inherit term taxonomy values;
          count = length values;
        })
        terms;
in
  env.lib.template.documentedTemplate {
    description = ''
      Template transforming raw taxonomy data.
    '';
    arguments = [
      {
        name = "taxonomyData";
        description = "Taxonomy data.";
        type = "Taxonomy";
      }
    ];
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.taxonomy.term-list (lib.proplist.getProp "tags" (lib.data.mkTaxonomyData {
            data = [
              { tags = [ "foo" "bar" ]; path = "/a.html"; }
              { tags = [ "foo" ];       path = "/b.html"; }
              { category = [ "baz" ];   path = "/c.html"; }
            ];
            taxonomies = [ "tags" "category" ];
          }))
        '';
        code = with env;
          templates.taxonomy.term-list (lib.proplist.getProp "tags" (lib.data.mkTaxonomyData {
            data = [
              {
                tags = ["foo" "bar"];
                path = "/a.html";
              }
              {
                tags = ["foo"];
                path = "/b.html";
              }
              {
                category = ["baz"];
                path = "/c.html";
              }
            ];
            taxonomies = ["tags" "category"];
          }));
      })
    ];
    inherit env template;
  }
