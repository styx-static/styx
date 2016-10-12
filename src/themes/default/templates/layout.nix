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
    ${templates.partials.head page}
  </head>

  <body>

    ${templates.partials.navbar.main}

    <div class="page-content">
      <div class="container wrapper">
        ${templates.partials.breadcrumbs page}
        ${page.content}
      </div>
    </div>

    <footer>
      ${templates.partials.footer}
    </footer>

  </body>
  </html>
''
