/* Display a taxonomy term information as a full page

   Require the page attribute set to define:
   - taxonomy
   - term
   - values
*/
{ lib, templates, ... }:
with lib;
normalTemplate (page: rec {
  title = "${page.taxonomy}: ${page.term}";
  content = ''
    <h1>${title}</h1>
    <ul>
      ${mapTemplate (value: ''
        <li>${templates.tag.ilink {
          page = value;
          content = value.title;
        }}</li>
      '') page.values}
    </ul>
  '';
})
