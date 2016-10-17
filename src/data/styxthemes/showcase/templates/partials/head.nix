{ conf, lib, templates, pages, ... }:
page:
with lib;
''
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width; initial-scale=1">
  ${generatorMeta}

  <title>${page.title} - ${conf.theme.site.title}</title>

  ${optionalString (pages ? feed) ''
  <link
      href="${conf.siteUrl}/${pages.feed.href}"
      type="application/atom+xml"
      rel="alternate"
      title="${conf.theme.site.title}"
      />
  ''}

  <link
      rel="stylesheet"
      type="text/css"
      href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

  <link
      rel="stylesheet"
      type="text/css"
      href="${conf.siteUrl}/font-awesome/css/font-awesome.min.css">

  <link
      rel="stylesheet"
      type="text/css"
      href="${conf.siteUrl}/css/style.css">
''
