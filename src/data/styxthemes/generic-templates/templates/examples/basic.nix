{ lib, templates, data, ... }:
lib.normalTemplate (page:

  /* In a normal site the navbar should be in templates.partials.content-pre
  */
  templates.bootstrap.navbar.default {
    inverted = true;
    brand = ''<a class="navbar-brand" href="#">Styx Generic Templates</a>'';
    content = [
      (templates.bootstrap.navbar.nav {
        items = data.navbar;
        currentPage = page;
      })
    ];
  } 

+ "<h1>Hello, world!</h1>"
)
