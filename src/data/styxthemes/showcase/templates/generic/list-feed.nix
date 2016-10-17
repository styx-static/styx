{ conf, lib, ... }:
with lib;
page:
''
  <entry>
    <id>${conf.siteUrl}/${page.href}</id>
    <link href="${conf.siteUrl}/${page.href}" rel="alternate" type="text/html"/>
    <updated>${page.date}T00:00:00Z</updated>
    <title>${page.title}</title>
    <summary type="xhtml">
      <div xmlns="http://www.w3.org/1999/xhtml">
        ${if (page ? intro) then page.intro else page.content}
      </div>
    </summary>
  </entry>
''
