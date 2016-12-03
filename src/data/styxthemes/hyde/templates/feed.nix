{ conf, lib, templates, ... }:
with lib;
page:
  ''
    <feed xmlns="http://www.w3.org/2005/Atom"
          xmlns:planet="http://namespace.uri/"
          xmlns:indexing="urn:atom-extension:indexing"
          indexing:index="no">

      <access:restriction xmlns:access="http://www.bloglines.com/about/specs/fac-1.0" relationship="deny"/>

      <title>${conf.theme.site.title}</title>
      <updated>${(head page.posts).date}T00:00:00Z"</updated>
      <generator>Styx</generator>
      <id>${conf.siteUrl}/atom.xml</id>
      <link href="${conf.siteUrl}/atom.xml" rel="self" type="application/atom+xml"/>
      <link href="${conf.siteUrl}" rel="alternate"/>
      
      ${mapTemplate templates.post.feed-list page.posts}

    </feed>
  ''
