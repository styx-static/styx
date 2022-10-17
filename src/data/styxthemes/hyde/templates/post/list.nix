{
  conf,
  lib,
  templates,
  ...
}:
with lib.lib;
  page: ''
    <div class="post">
      <h1 class="post-title">${templates.tag.ilink {to = page;}}</h1>
      <span class="post-date">${with (lib.template.parseDate page.date); "${D} ${b} ${Y}"}</span>
      ${page.intro}
    </div>
  ''
