{
  lib,
  templates,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (page: ''
    <h1>${page.title}</h1>
    <span class="post-date">${with (lib.template.parseDate page.date); "${D} ${b}, ${Y}"}</span>
    <div class="post-content">
    ${page.content}

    ${optionalString (page ? multipages) (templates.bootstrap.pager {inherit (page.multipages) pages index;})}
    </div>
  '')
