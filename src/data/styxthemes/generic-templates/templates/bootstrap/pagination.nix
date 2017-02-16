env:

let template = { lib, templates, ... }:
  { pages, index }:
  with lib;
  let
    prevHref = if (index > 1)
               then templates.url (elemAt pages (index - 2))
               else "#";
    nextHref = if (index < (length pages))
               then templates.url (elemAt pages index)
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
