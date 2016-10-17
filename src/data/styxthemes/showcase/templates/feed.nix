{ conf, state, lib, templates, data, ... }:
with lib;
page:
''
  <feed xmlns="http://www.w3.org/2005/Atom"
        xmlns:planet="http://namespace.uri/"
        xmlns:indexing="urn:atom-extension:indexing"
        indexing:index="no">

    <access:restriction xmlns:access="http://www.bloglines.com/about/specs/fac-1.0" relationship="deny"/>

    <title>${if (page ? title) then page.title else conf.theme.site.title}</title>
    <updated>${state.lastChange}</updated>
    <generator>Styx</generator>
    <id>${conf.siteUrl}/${page.href}</id>
    <link href="${conf.siteUrl}/${page.href}" rel="self" type="application/atom+xml"/>
    <link href="${conf.siteUrl}" rel="alternate"/>
    
    ${mapTemplate templates.generic.list-feed page.items}

  </feed>
''
