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
  ''
  <nav aria-label="...">
  <ul class="pager">
  <li${optionalString (index == 1) " ${htmlAttr "class" "disabled"}"}><a ${htmlAttr "href" prevHref}>Previous</a></li>
  <li${optionalString (index == (length pages)) " ${htmlAttr "class" "disabled"}"}><a ${htmlAttr "href" nextHref}>Next</a></li>
  </ul>
  </nav>
  '';

in with env.lib; documentedTemplate {
  description = "Generate a pager";
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
      templates.bootstrap.pager {
        pages = genList (x: { path = "/#''${toString (x + 1)}"; }) 10;
        index = 5;
      }
    '';
    code = with env; 
      templates.bootstrap.pager {
        pages = genList (x: { path = "/#${toString (x + 1)}"; }) 10;
        index = 5;
      }
    ;
  }) ];
  inherit env template;
}
