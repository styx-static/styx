{ conf, lib, templates, data, ... }:
{ page }:
with lib;
templates.bootstrap.navbar.default {
  id = "main-nav";
  brand = ''<a class="navbar-brand page-scroll" href="#page-top">${conf.theme.site.title}</a>'';
  extraClasses = [ "navbar-fixed-top" ];
  content = [
    (templates.bootstrap.navbar.nav {
      align = "right";
      items = data.menu;
      currentPage = page;
    })
  ];
}

