/* Pagination template, take two parameters:

   - pages: A list of pages
   - index: The current page index

   Usage example in a template used with the `splitPage` function:

     templates.pagination { pages = page.pages; index = page.index; }

*/
{ lib, conf, ... }:
{ pages, index }:
  with lib;
  ''
  <nav aria-label="Page navigation">
    <ul class="pagination">
      <li${optionalString (index == 1) " ${htmlAttr "class" "disabled"}"}>
        <a href=${if (index > 1) then "\"${conf.siteUrl}/${(elemAt pages (index - 2)).href}\"" else "\"#\""} aria-label="Previous">
          <span aria-hidden="true">&laquo;</span>
        </a>
      </li>
      ${concatStringsSep "\n" (imap (i: page: ''
      <li${optionalString (i == index) " ${htmlAttr "class" "active"}"}><a href="${conf.siteUrl}/${page.href}">${toString i}</a></li>
      '') pages)}
      <li>
      <li${optionalString (index == (length pages)) " ${htmlAttr "class" "disabled"}"}>
        <a href=${if (index < (length pages)) then "\"${conf.siteUrl}/${(elemAt pages (index)).href}\"" else "\"#\""} aria-label="Next">
          <span aria-hidden="true">&raquo;</span>
        </a>
      </li>
    </ul>
  </nav>
  ''
