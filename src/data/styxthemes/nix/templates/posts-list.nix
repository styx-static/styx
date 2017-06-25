{ lib, templates, pages, ... }:
with lib;
lib.normalTemplate (page: ''
  <h1 class="text-center">${page.title}</h1>

  <ul id="post-list">
  ${mapTemplate templates.post.list page.items}
  </ul>

  ${optionalString (page ? pages) ''
    <div class="text-center">
      ${templates.bootstrap.pagination { inherit (page) pages index; }}
    </div>
  ''}
'')

