/* Pagination template, take two parameters:

   - pages: A list of pages
   - index: The current page index

   Usage example in a template used with the `splitPage` function:

     templates.pagination { pages = page.pages; index = page.index; }

*/
{ lib, conf, ... }:
{ pages, index }:
  with lib;
  let
    prevHref = if (index > 1) then "${conf.siteUrl}/${(elemAt pages (index - 2)).href}" else "#";
    nextHref = if (index < (length pages)) then "${conf.siteUrl}/${(elemAt pages (index)).href}" else "#";
  in

  optionalString ((length pages) > 1)
  ''
    <div class="pagination">
      ${if (index == 1) then ''
      <span class="previous">Previous</span>
      '' else ''
      <a href="${prevHref}" class="previous">Previous</a>
      ''}
      ${if (index == (length pages)) then ''
      <span class="next">Next</span>
      '' else ''
      <a href="${nextHref}" class="next">Next</a>
      ''}
    </div>
  ''
