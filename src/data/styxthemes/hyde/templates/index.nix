{
  conf,
  lib,
  templates,
  data,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (page: ''
    <div class="posts">
      ${lib.template.mapTemplate templates.post.list (page.items or [])}
    </div>

    ${optionalString (page ? pages) (templates.partials.pager {inherit (page) pages index;})}
  '')
