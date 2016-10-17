/* Taxonomy for a content displayed
   
   This template render the taxonomy terms for a page.

   tags: foo bar
*/
{ conf, lib, templates, ... }:
{ taxonomy, page, title ? null, sep ? " " }:
with lib;
optionalString (hasAttr taxonomy page)
''
  <p>
    ${if (title != null)
         then title
         else "${taxonomy}: "}
    ${concatMapStringsSep sep (term: ''
      <a href="${conf.siteUrl}/${taxonomy}/${term}/">${term}</a> 
  '') page."${taxonomy}"}</p>
''
