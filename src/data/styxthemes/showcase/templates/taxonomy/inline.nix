/* Taxonomy for a content displayed
   
   This template render the taxonomy terms for a page.

   tags: foo bar
*/
{ conf, lib, ... }:
{ taxonomy, page }:
with lib;
optionalString (hasAttr taxonomy page)
''
  <p>${taxonomy}: ${mapTemplate (term: ''
    <a href="${conf.siteUrl}/${taxonomy}/${term}/">${term}</a> 
  '') page."${taxonomy}"}</p>
''
