{ conf, lib, templates
, navbar ? false
, feed ? false
, ... }:

page:
with lib;
  ''
    <!DOCTYPE html>
    <html>
  
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width; initial-scale=1">
  
      <title>${page.title} - ${conf.siteTitle}</title>
  
      ${optionalString (feed != false) ''
      <link
          href="${conf.siteUrl}/${feed.href}"
          type="application/atom+xml"
          rel="alternate"
          title="${conf.siteTitle}"
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
    </head>
  
    <body${optionalString (navbar != false) " ${htmlAttr "class" "with-navbar"}"}>
  
      ${if (navbar != false)
          then (templates.navbar.main navbar)
          else ''
            <header class="site-header">
              <div class="container wrapper">
                <a class="site-title" href="${conf.siteUrl}">${conf.siteTitle}</a>
              </div>
            </header>
          ''}

      <div class="page-content">
        <div class="container wrapper">
          ${templates.breadcrumbs page}
          ${page.content}
        </div>
      </div>

      <footer>
        <div class="container wrapper">
          <div class="row">
            <div class="col-sm-4 col-xs-4">
              <p>${conf.siteTitle}</p>
            </div>
            <div class="col-sm-4 col-xs-4">
              <ul class="list-unstyled">
                <li><a href="https://nixos.org/nix/">Nix</a></li>
              </ul>
            </div>
            <div class="col-sm-4 col-xs-4">
              <p>${conf.siteDescription}</p>
            </div>
          </div>
        </div>
      </footer>
  
    </body>
    </html>
  ''
