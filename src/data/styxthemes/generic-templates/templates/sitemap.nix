{ conf, lib, templates, ... }:
page:
with lib;
''
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ${mapTemplate (page: ''
  <url>
    <loc>${templates.purl page}</loc>
    <changefreq>${page.changefreq or "monthly"}</changefreq>
  </url>'') page.pages}
</urlset> 
''
