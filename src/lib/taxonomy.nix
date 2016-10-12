# Taxonomy functions

lib:
with lib;
let
  proplistLib = import ./proplist.nix lib;
in
rec {

  /* create a taxonomy data structure
  */
  mkTaxonomyData = { pages, taxonomies }:
   fold (taxonomy: set:
     fold (page: set:
       fold (term: set: let 
         taxonomySet = 
           if hasAttr taxonomy set
              then set
              else set // { "${taxonomy}" = []; };
         proplist = (getAttrFromPath [ taxonomy ] taxonomySet);
         prop = { "${term}" = [ page ]; };
       in 
         taxonomySet // { "${taxonomy}" = proplistLib.merge proplist prop; } 
       ) set page."${taxonomy}"
     ) set (filter (page: hasAttr taxonomy page) pages)
   ) {} taxonomies;

  /* create taxonomy pages
  */
  mkTaxonomyPages = { pages, taxonomies, taxonomyTemplate, termTemplate }:
    let
      taxonomyData = mkTaxonomyData { inherit pages taxonomies; };
      taxonomyPages = mapAttrsToList (taxonomy: terms:
        { inherit terms taxonomy;
          href = "${taxonomy}/index.html";
          template = taxonomyTemplate;
          title = taxonomy; }
      ) taxonomyData; 
      termPages = flatten (mapAttrsToList (taxonomy: terms:
        map (term:
          { inherit taxonomy;
            href     = "${taxonomy}/${proplistLib.propKey term}/index.html";
            template = termTemplate;
            title    = proplistLib.propKey   term;
            term     = proplistLib.propKey   term;
            values   = proplistLib.propValue term; }
        ) terms
      ) taxonomyData);
  in (termPages ++ taxonomyPages);

}
