env:

let template = { lib, templates, ... }:
  { pages, index, pagesLimit ? null }:
  with lib;
  let
    prevHref = if (index > 1)
               then templates.url (elemAt pages (index - 2))
               else "#";
    nextHref = if (index < (length pages))
               then templates.url (elemAt pages index)
               else "#";
    offset = 
      let minLimit = (pagesLimit / 2);
          maxLimit = (length pages) - minLimit;
      in if pagesLimit == null then 0
         else if index < minLimit then 0
         else if index > maxLimit then (length pages) - pagesLimit
         else index - minLimit - 1;
    pages' = 
      if pagesLimit != null
      then take pagesLimit (drop offset pages)
      else pages;
  in
  optionalString ((length pages) > 1) ''
  <nav aria-label="Page navigation" class="pagination">
  <ul class="pagination">
  <li${optionalString (index == 1) " ${htmlAttr "class" "disabled"}"}>
  <a ${htmlAttr "href" prevHref} aria-label="Previous">
  <span aria-hidden="true">&laquo;</span>
  </a>
  </li>
  ${concatStringsSep "\n" (imap (i: page: 
  let i' = i + offset; in
  ''
  <li${optionalString (i' == index) " ${htmlAttr "class" "active"}"}>${templates.tag.ilink { to = page; content = toString i'; } }</li>''
  ) pages')}
  <li${optionalString (index == (length pages)) " ${htmlAttr "class" "disabled"}"}>
  <a ${htmlAttr "href" nextHref} aria-label="Next">
  <span aria-hidden="true">&raquo;</span>
  </a>
  </li>
  </ul>
  </nav>
  '';

in with env.lib; documentedTemplate {
  description = "Generate a pagination";
  arguments = {
    pages = {
      description = "List of pages.";
      type = "[ Page ]";
    };
    index = {
      description = "Index of the current page.";
      type = "Integer";
    };
    pagesLimit = {
      description = "Maximum number of pages to show in the pagination, if set to `null` all pages are in the pagination.";
      type = "Null | Int";
      default = null;
    };
  };
  examples = [ (mkExample {
    literalCode = ''
      templates.bootstrap.pagination {
        pages = genList (x: { path = "/#''${toString (x + 1)}"; }) 10;
        index = 5;
      }
    '';
    code = with env;
      templates.bootstrap.pagination {
        pages = genList (x: { path = "/#${toString (x + 1)}"; }) 10;
        index = 5;
      }
    ;
  }) ];
  inherit env template;
}
