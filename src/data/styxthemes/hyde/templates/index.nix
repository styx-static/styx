{ conf, lib, templates, data, ... }:
page:
with lib;
let content =
  ''
  <div class="posts">
    ${mapTemplate templates.post.list (page.items or [])}
  </div>

  ${templates.partials.pagination { pages = (page.pages or []); index = page.index; }} 
  '';
in
 page // { inherit content; }
