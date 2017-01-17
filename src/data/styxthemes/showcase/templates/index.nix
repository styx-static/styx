{ conf, templates, lib, ... }:
with lib;
normalTemplate (page: ''
  <h1>${page.title}</h1>
  ${mapTemplate (ps:
      ''<div class="row">''
    + (mapTemplate templates.post.preview ps)
    + "</div>"
  ) (chunksOf 2 page.items)}

  ${templates.bootstrap.pagination { inherit (page) pages index; }}
'')
