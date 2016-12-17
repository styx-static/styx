{ conf, lib, templates, ... }:
page:
with lib;
''
  <!DOCTYPE html>
  <html ${optionalString (conf.theme.site ? languageCode) htmlAttr "lang" conf.theme.site.languageCode}>

  <head>
    ${templates.partials.head page}
  </head>

  <body>

    ${templates.partials.navbar.main page}

    <div class="page-content">
      <div class="container wrapper">
        <div class="row">
          <div class="col-md-9">
            ${templates.partials.breadcrumbs page}
            ${page.content}
          </div>
          <div class="col-md-3">
            ${templates.partials.sidebar}
          </div>
        </div>
      </div>
    </div>

    ${templates.partials.footer}

    ${templates.partials.js}
  </body>
  </html>
''
