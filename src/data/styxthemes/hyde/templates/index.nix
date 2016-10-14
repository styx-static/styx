{ conf, lib, templates, data, ... }:
page:
with lib;
let content =
  ''
  <div class="posts">
    ${mapTemplate templates.post.list page.items}
  </div>

  ${templates.partials.pagination { pages = page.pages; index = page.index; }} 
  '';
in
 page // { inherit content; }
