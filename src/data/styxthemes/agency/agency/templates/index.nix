{ templates, ... }:
page:
''
<!DOCTYPE html>
<html lang="en-US">
<head>
  ${templates.partials.head}
</head>
  <body id="page-top" class="index">
    ${templates.partials.nav}
    ${templates.partials.hero}
    ${templates.partials.services}
    ${templates.partials.portfolio}
    ${templates.partials.about}
    ${templates.partials.team}
    ${templates.partials.clients}
    ${templates.partials.contact}
    ${templates.partials.footer}
    ${templates.partials.modals}
    ${templates.partials.js}
  </body>
</html>
''
