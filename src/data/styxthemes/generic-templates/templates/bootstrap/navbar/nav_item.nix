env: let
  template = {
    lib,
    conf,
    templates,
    ...
  }: {
    item,
    currentPage ? null,
    ...
  }:
    with lib.lib; let
      isCurrent = item:
        (currentPage
          != null
          && currentPage ? breadcrumbs
          && item ? path
          && elem item.path (map (p: p.path) currentPage.breadcrumbs))
        || (currentPage != null && item ? path && currentPage.path == item.path);
      active = optionalString (isCurrent item) (" " + lib.template.htmlAttr "class" "active");
      title = item.navbarTitle or item.title;
      href = lib.template.htmlAttr "href" (templates.url (attrByPath ["url"] item item));
      class = optionalString (item ? navbarClass) (" " + lib.template.htmlAttr "class" item.navbarClass);
    in ''
      <li${active}><a ${href}${class}>${title}</a></li>'';
in
  env.lib.template.documentedTemplate {
    description = "Generate a navbar nav item. Used internally by `bootstrap.navbar.nav`.";
    arguments = [
      {
        name = "item";
        description = "Item";
        type = "Page";
      }
      {
        name = "currentPage";
        description = "Current page displayed.";
        type = "[ Page ]";
      }
    ];
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''templates.bootstrap.navbar.nav_item { item = { title = "Home"; path = "/"; }; }'';
        code = with env;
          templates.bootstrap.navbar.nav_item {
            item = {
              title = "Home";
              path = "/";
            };
          };
      })
    ];
    inherit env template;
  }
