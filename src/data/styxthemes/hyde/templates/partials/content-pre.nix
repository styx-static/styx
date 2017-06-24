{ conf, lib, templates, data, ... }:
{ page }:
with lib;
''
<div class="sidebar">
  <div class="container sidebar-sticky">
    <div class="sidebar-about">
      ${templates.tag.ilink { to = "/"; content = "<h1>${conf.theme.site.title}</h1>"; }}
      ${optionalString (conf.theme.site.description != "") ''<p class="lead">${conf.theme.site.description}</p>''}
    </div>

    <ul class="sidebar-nav">
      <li>${templates.tag.ilink { to = "/"; content = "Home"; }}</li>
      ${mapTemplate (menu: ''
        <li>${templates.tag.ilink { to = menu; content = menu.title; }}</li>
      '') (data.menu or [])}
    </ul>

    ${optionalString (conf.theme.site.copyright != "") ''<p>${conf.theme.site.copyright}</p>''}
  </div>
</div>
''
