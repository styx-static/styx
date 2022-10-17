env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }: page:
    with lib.lib; ''
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
        ${lib.template.mapTemplate (page: ''
        <url>
          <loc>${templates.url page}</loc>
          <changefreq>${page.changefreq or "monthly"}</changefreq>
        </url>'')
      page.pages}
      </urlset>
    '';
in
  env.lib.template.documentedTemplate {
    description = ''
      Template generating a link:https://en.wikipedia.org/wiki/Sitemaps[sitemap file]. +
      Take a page with a `pages` attribute containing the list of pages to include in the sitemap. +
      Pages in the list can define a `changefreq` attribute, else `monthly` will be used.
    '';
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          sitemap = {
            path     = "/sitemap.xml";
            template = templates.sitemap;
            layout   = lib.id;
            pages    = lib.pagesToList { inherit pages; };
          };
        '';
      })
    ];
    inherit env template;
  }
