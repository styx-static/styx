env:

let template = { lib, conf, templates, ... }:
  { title
  , items
  , caret ? '' <span class="caret"></span>''
  , ... }:
  with lib;
    ''
     <li class="dropdown">
     <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">${title}${caret}</a>
     <ul class="dropdown-menu">
     ${mapTemplate (item: templates.bootstrap.navbar.nav_item { inherit item; }) items}
     </ul>
     </li>'';

in with env.lib; documentedTemplate {
  description = "Generate a navbar nav dropdown menu. Meant to be used in `bootstrap.navbar.nav` context";
  arguments = [
    {
      name = "title";
      description = "Title";
      type = "String";
    }
    {
      name = "items";
      description = "Items of the dropdown menu";
      type = "[ Page ]";
    }
    {
      name = "caret";
      description = "Code added after the dropdown title";
      type = "String";
      default = '' <span class="caret"></span>'';
    }
  ];
  examples = [ (mkExample {
    literalCode  = ''templates.bootstrap.navbar.nav_dropdown { title = "Languages"; items = [ { title = "English"; path = "/eng"; } { title = "French"; path = "/fre"; } ]; }'';
    code = with env; templates.bootstrap.navbar.nav_dropdown { title = "Languages"; items = [ { title = "English"; path = "/eng"; } { title = "French"; path = "/fre"; } ]; };
  }) ];
  inherit env template;
}
