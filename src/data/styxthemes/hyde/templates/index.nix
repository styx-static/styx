{ conf, lib, templates, data, ... }:
with lib;
normalTemplate (page: ''
  <div class="posts">
    ${mapTemplate templates.post.list (page.items or [])}
  </div>

  ${optionalString (page ? pages) (templates.partials.pager { inherit (page) pages index; })} 
'')
