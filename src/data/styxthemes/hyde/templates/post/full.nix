{
  lib,
  templates,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (page: ''
    <div class="post">
      <h1>${page.title}</h1>
      <span class="post-date">${with (lib.template.parseDate page.date); "${D} ${b} ${Y}"}</span>
      ${page.content}

      ${optionalString (page ? multipages) (templates.partials.pager {inherit (page.multipages) pages index;})}
    </div>
  '')
