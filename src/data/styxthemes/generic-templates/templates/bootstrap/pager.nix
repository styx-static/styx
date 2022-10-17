env: let
  template = {
    lib,
    templates,
    ...
  }: {
    pages,
    index,
  }:
    with lib.lib; let
      prevItem =
        if (index > 1)
        then elemAt pages (index - 2)
        else null;
      nextItem =
        if (index < (length pages))
        then elemAt pages index
        else null;
    in ''
      <nav aria-label="...">
      <ul class="pager">
      ${optionalString (prevItem != null)
        ''<li class="previous">${templates.tag.ilink {
            to = prevItem;
            content = ''<span aria-hidden="true">&larr;</span> ${prevItem.title or "Previous"}'';
          }}</li>''}
      ${optionalString (nextItem != null)
        ''<li class="next">${templates.tag.ilink {
            to = nextItem;
            content = ''${nextItem.title or "Next"} <span aria-hidden="true">&rarr;</span>'';
          }}</li>''}
      </ul>
      </nav>
    '';
in
  env.lib.template.documentedTemplate {
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
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.bootstrap.pager {
            pages = genList (x: { path = "/#''${toString (x + 1)}"; }) 10;
            index = 5;
          }
        '';
        code = with env;
        with env.lib.lib;
          templates.bootstrap.pager {
            pages = genList (x: {path = "/#${toString (x + 1)}";}) 10;
            index = 5;
          };
      })
    ];
    inherit env template;
  }
