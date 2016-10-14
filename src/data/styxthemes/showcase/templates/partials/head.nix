{ conf, feed, lib, templates, ... }:
page:
with lib;
''
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width; initial-scale=1">
  ${generatorMeta}

  <title>${page.title} - ${conf.theme.site.title}</title>

  ${optionalString (feed != false) ''
  <link
      href="${conf.siteUrl}/${feed.href}"
      type="application/atom+xml"
      rel="alternate"
      title="${conf.theme.site.title}"
      />
  ''}

  <link
      rel="stylesheet"
      href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

  <script
    src="https://code.jquery.com/jquery-3.1.1.min.js"
    crossorigin="anonymous"></script>

  <script
    src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    crossorigin="anonymous"></script>

  <link
      rel="stylesheet"
      href="${conf.siteUrl}/style.css">
''
