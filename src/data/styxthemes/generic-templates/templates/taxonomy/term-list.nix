env:

let template = { templates, lib, ... }:
  with lib;
  taxonomyData:
  let
    taxonomy = proplist.propKey   taxonomyData;
    terms    = proplist.propValue taxonomyData;
  in
    map (prop:
      let term    = proplist.propKey   prop;
          values  = proplist.propValue prop;
      in
        { path = mkTaxonomyTermPath taxonomy term;
          inherit term taxonomy values;
          count = length values; }) terms;

in with env.lib; documentedTemplate {
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
  examples = [ (mkExample {
    literalCode = ''
      templates.taxonomy.term-list (getProp "tags" (mkTaxonomyData {
        data = [
          { tags = [ "foo" "bar" ]; path = "/a.html"; }
          { tags = [ "foo" ];       path = "/b.html"; }
          { category = [ "baz" ];   path = "/c.html"; }
        ];
        taxonomies = [ "tags" "category" ];
      }))
    '';
    code = with env;
      templates.taxonomy.term-list (getProp "tags" (mkTaxonomyData {
        data = [
          { tags = [ "foo" "bar" ]; path = "/a.html"; }
          { tags = [ "foo" ];       path = "/b.html"; }
          { category = [ "baz" ];   path = "/c.html"; }
        ];
        taxonomies = [ "tags" "category" ];
      }))
    ;
  }) ];
  inherit env template;
}
