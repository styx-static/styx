{ conf, ... }:
post:
  ''
    <entry>
      <id>${conf.siteUrl}/${post.href}</id>
      <link href="${conf.siteUrl}/${post.href}" rel="alternate" type="text/html"/>
      <updated>${post.date}T00:00:00Z</updated>
      <title>${post.title}</title>
      <summary type="xhtml">
        <div xmlns="http://www.w3.org/1999/xhtml">
          ${post.content}
        </div>
      </summary>
    </entry>
  ''
