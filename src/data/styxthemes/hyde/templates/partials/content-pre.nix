{ conf, lib, templates, data, ... }:
page:
with lib;
''
<div class="sidebar">
  <div class="container sidebar-sticky">
    <div class="sidebar-about">
      ${templates.tag.ilink { path = "/"; content = "<h1>${conf.theme.site.title}</h1>"; }}
      ${optionalString (conf.theme.site ? description) ''<p class="lead">${conf.theme.site.description}</p>''}
    </div>

    <ul class="sidebar-nav">
      <li>${templates.tag.ilink { path = "/"; content = "Home"; }}</li>
      ${mapTemplate (menu: ''
        <li>${templates.tag.ilink { page = menu; content = menu.title; }}</li>
      '') (data.menu or [])}
    </ul>

    <p>&copy; 2016. All rights reserved.</p>
  </div>
</div>
''
