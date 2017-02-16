env:

let template = { lib, conf, templates, ... }:
  page:
  with lib;
  optionalString (page ? breadcrumbs) ''
  <ol class="breadcrumb">
  ${mapTemplate (p: 
    "  <li>${templates.tag.ilink { content = p.breadcrumbTitle or p.title; page = p;  }}</li>"
  ) page.breadcrumbs}
    <li class="active">${page.breadcrumbTitle or page.title}</li>
  </ol>
  '';

in with env.lib; documentedTemplate {
  description = "Generate a page breadcrumbs; takes a page attribute with a `breadcrumbs` attribute containing a list of pages.";
  arguments = [
    {
      name = "page";
      description = "The page to generate breadcrumbs from.";
      type = "Page";
    }
  ];
  examples = [ (mkExample {
    literalCode = ''
      templates.bootstrap.breadcrumbs {
        path = "/about.html";
        title = "About";
        breadcrumbs = [ { path = "/"; breadcrumbTitle = "Home"; title = "My site"; } ];
      }
    '';
    code = with env;
      templates.bootstrap.breadcrumbs {
        path = "/about.html";
        title = "About";
        breadcrumbs = [ { path = "/"; breadcrumbTitle = "Home"; title = "My site"; } ];
      }
    ;
  }) ];
  inherit env template;
}
