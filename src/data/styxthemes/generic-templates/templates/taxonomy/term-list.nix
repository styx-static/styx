/* Generate a list of taxonomy terms for a taxonomy data structure

   Takes a taxonomy data structure in the format:
   
     {
       TAXONOMY = [
         { TERM1 = [ VALUE1 VALUE2 ... ]; }
         { TERM2 = [  ... ]; }
         ...
       ];
     }

   return a list of attribute sets in the form:

     [ { path = "/..."; number = N; taxonomy = ...; term = ...; values = [ { ... } ]; } ]


*/
{ templates, lib, ... }:
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
      { path = templates.taxonomy.term.path { inherit taxonomy term; };
        inherit term taxonomy values;
        number = length values; }) terms
