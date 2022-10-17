env: let
  template = {
    lib,
    templates,
    data,
    ...
  }:
    lib.template.normalTemplate (
      page:
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
    );
in
  env.lib.template.documentedTemplate {
    description = "Template for the example site, internal use only.";
    inherit env template;
  }
