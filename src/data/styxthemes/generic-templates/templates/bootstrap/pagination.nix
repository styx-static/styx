/* Bootstrap pagination template, take two parameters:

   - pages: A list of pages
   - index: The current page index

   Usage example in a template used with the `splitPage` function:

     templates.pagination { pages = page.pages; index = page.index; }

*/
{ lib, conf, templates, ... }:
{ pages, index }:
with lib;
let
  prevHref = if (index > 1)
             then templates.purl (elemAt pages (index - 2))
             else "#";
  nextHref = if (index < (length pages))
             then templates.purl (elemAt pages index)
             else "#";
in

optionalString ((length pages) > 1) ''
<nav aria-label="Page navigation" class="pagination">
<ul class="pagination">
<li${optionalString (index == 1) " ${htmlAttr "class" "disabled"}"}>
<a ${htmlAttr "href" prevHref} aria-label="Previous">
<span aria-hidden="true">&laquo;</span>
</a>
</li>
${concatStringsSep "\n" (imap (i: page: ''
<li${optionalString (i == index) " ${htmlAttr "class" "active"}"}>${templates.tag.ilink { inherit page; content = toString i; } }</li>''
) pages)}
<li${optionalString (index == (length pages)) " ${htmlAttr "class" "disabled"}"}>
<a ${htmlAttr "href" nextHref} aria-label="Next">
<span aria-hidden="true">&raquo;</span>
</a>
</li>
</ul>
</nav>
''
