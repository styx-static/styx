{ templates, data, conf, ... }:
{ page }:
templates.bootstrap.navbar.default {
  brand = ''<a class="navbar-brand" href="${conf.siteUrl}">${conf.theme.site.title}</a>'';
  extraClasses = [ "navbar-fixed-top" ];
  content = [
    (templates.bootstrap.navbar.nav {
      align = "right";
      items = data.navbar;
      currentPage = page;
    })
  ];
} 
