{
  conf,
  templates,
  lib,
  ...
}:
lib.template.normalTemplate (page: ''
  <h1>${page.title}</h1>
  ${lib.template.mapTemplate (
    ps:
      ''<div class="row">''
      + (lib.template.mapTemplate templates.post.preview ps)
      + "</div>"
  ) (lib.utils.chunksOf 2 page.items)}

  ${templates.bootstrap.pagination {inherit (page) pages index;}}
'')
