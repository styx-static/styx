{ conf, lib, templates, ... }:
page:
with lib;
''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>${page.title or conf.theme.site.title}</title>
  ${optionalString (page ? subtitle) "<subtitle>${page.subtitle}</subtitle>"}
  <generator>Styx</generator>
  <updated>${(parseDate (head page.items).date).T}</updated>
  <id>${templates.purl page}</id>
  <link href="${templates.purl page}" rel="self" type="application/atom+xml"/>
  <link href="${templates.url "/"}" rel="alternate"/>
  ${if (page ? author) then ''
  <author>
    <name>${page.author.name}</name>
    ${optionalString (page.author ? email) "<email>${page.author.email}</email>"}
    ${optionalString (page.author ? uri)   "<uri>${page.author.email}</uri>"}
  </author>
  '' else ''
  <author>
    <name>Styx</name>
  </author>
  ''}
  ${optionalString (page ? icon) "<icon>${page.icon}</icon>"}
  ${optionalString (page ? logo) "<logo>${page.logo}</logo>"}
  ${mapTemplate templates.feed.atom-list page.items}
</feed>
''
