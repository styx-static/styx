env:

let template = { lib, conf, templates, ... }:
  { items
  , align ? null
  , currentPage ? null
  , ... }:
  with lib;
  let
    extraClasses = optionalString (align != null) " navbar-${align}";
    isCurrent = item:
        (currentPage != null && currentPage ? breadcrumbs && item ? path
         && elem item.path (map (p: p.path) currentPage.breadcrumbs))
     || (currentPage != null && item ? path && currentPage.path == item.path);
  in
  ''
  <ul class="nav navbar-nav${extraClasses}">
  ${mapTemplate (item:
    let
      class = optionalString (isCurrent item) (" " + htmlAttr "class" "active");
      href  = htmlAttr "href" (if (item ? url) then item.url else templates.url item);
      title = item.navbarTitle or item.title;
    in ''
    <li${class}><a ${href}>${title}</a></li>''
  ) items}
  </ul>'';

in with env.lib; documentedTemplate {
  description = "Template to generate a navbar navigation list. Meant to be used in `bootstrap.navbar.default` `content` parameter.";
  arguments = {
    items = {
      description = "Items of the navbar.";
      type = "[ Pages ]";
    };
    align = {
      description = "Alignment of the navigation.";
      type = ''"right", "left" or null'';
      default = null;
    };
    currentPage = {
      description = "Current page viewed, used to make active the menu corresponding to the current page.";
      default = null;
      type = "Page or null";
    };
  };
  examples = [ (mkExample {
    literalCode = ''
      templates.bootstrap.navbar.nav {
        items = [
        { title = "Home";    path = "/#"; }
        { title = "About";   path = "/#about"; }
        { title = "Contact"; path = "/#contact"; }
        ];
        currentPage = { title = "Home"; path = "/#"; };
      }
    '';
    code = with env;
      templates.bootstrap.navbar.nav {
        items = [
        { title = "Home";    path = "/#"; }
        { title = "About";   path = "/#about"; }
        { title = "Contact"; path = "/#contact"; }
        ];
        currentPage = { title = "Home"; path = "/#"; };
      }
    ;
  }) ];
  inherit template env;
}
