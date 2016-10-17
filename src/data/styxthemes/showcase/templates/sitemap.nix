{ conf, state, lib, templates, ... }:
with lib;
page:
''
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ${mapTemplate (url: ''
  <url>
    <loc>${conf.siteUrl}/${url.href}</loc>
    <lastmod>${state.lastChange}</lastmod>
    <changefreq>monthly</changefreq>
  </url>'') page.urls}
</urlset> 
''
