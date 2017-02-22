{ conf, lib, templates, ... }:
with lib;
page:
''
  <div class="post">
    <h1 class="post-title">${templates.tag.ilink { to = page; }}</h1>
    <span class="post-date">${with (parseDate page.date); "${D} ${b} ${Y}"}</span>
    ${page.intro}
  </div>
''
