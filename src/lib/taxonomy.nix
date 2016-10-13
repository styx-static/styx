# Taxonomy functions

lib:
with lib;
let
  plib = import ./proplist.nix lib;
in
rec {

  /* Generate a taxonomy data structure
  */
  mkTaxonomyData = { pages, taxonomies }:
   let
     rawTaxonomy =
       fold (taxonomy: plist:
         fold (page: plist:
           fold (term: plist:
             plist ++ [ { "${taxonomy}" = [ { "${term}" = [ page ]; } ]; } ]
           ) plist page."${taxonomy}"
         ) plist (filter (page: hasAttr taxonomy page) pages)
       ) [] taxonomies;
     semiCleanTaxonomy = plib.flatten rawTaxonomy;
     cleanTaxonomy = map (pl:
       { "${plib.propKey pl}" = plib.flatten (plib.propValue pl); }
     ) semiCleanTaxonomy;
   in cleanTaxonomy;

  /* Generate taxonomy pages attribute sets
  */
  mkTaxonomyPages = { data, taxonomyTemplate, termTemplate }:
    let
      taxonomyPages = map (plist:
        let taxonomy = plib.propKey   plist;
            terms    = plib.propValue plist;
        in
        { inherit terms taxonomy;
          href = "${taxonomy}/index.html";
          template = taxonomyTemplate;
          title = taxonomy; }
      ) data; 
      termPages = flatten (map (plist:
        let taxonomy = plib.propKey   plist;
            terms    = plib.propValue plist;
        in
        map (term:
          { inherit taxonomy;
            href     = "${taxonomy}/${plib.propKey term}/index.html";
            template = termTemplate;
            title    = plib.propKey   term;
            term     = plib.propKey   term;
            values   = plib.propValue term; }
        ) terms
      ) data);
  in (termPages ++ taxonomyPages);

  /* sort terms by number of values
  */
  sortTerms = sort (a: b:
    valuesNb a > valuesNb b
  );

  /* Number of values a term holds
  */
  valuesNb = x: length (plib.propValue x);

}
