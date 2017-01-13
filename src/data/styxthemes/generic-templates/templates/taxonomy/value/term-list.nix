/* return a list of taxonomy terms data for a page in format:

     { path = ...; taxonomy = ...; term = ...; }
*/

{ lib, templates, ... }:
{ taxonomy
, page }:
with lib;

optionals
  (hasAttr taxonomy page)
  map (term: {
    path    = templates.taxonomy.term.path { inherit taxonomy term; };
    inherit taxonomy term;
  }) page."${taxonomy}"
