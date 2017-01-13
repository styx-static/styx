/* Display a taxonomy information as a full page

   Require the page attribute set to define:
   - taxonomy
   - taxonomyData
*/
{ conf, lib, templates, ... }:
with lib;
normalTemplate(page: rec {
  title = page.taxonomy;
  content = 
  ''
    <h1>${title}</h1>
    <ul>
    ${mapTemplate (t: ''
      <li>${templates.tag.ilink {
        path = t.path;
        content = t.term;
      }} (${toString t.number})</li>
    ''
    ) (templates.taxonomy.term-list page.taxonomyData)}
    </ul>
  '';
})
