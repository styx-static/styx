{ conf, lib, templates, data, ... }:
{ page }:
with lib;
templates.bootstrap.navbar.default {
  inverted = true;
  fluid = true;
  brand = ''<a class="navbar-brand" id="green-terminal" href="${templates.url "/"}">${conf.theme.site.title}</a>'';
  extraClasses = [ "navbar-fixed-top" "font-header" ];
  content = [
    (templates.bootstrap.navbar.nav {
      align = "right";
      items = data.menu;
      currentPage = page;
    })
  ];
}
