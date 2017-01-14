{ conf, templates, lib, ... }:
with lib;
normalTemplate (page: 
  ''
    <h1>${page.title}</h1>
    <div class="clearfix">
    ${mapTemplateWithIndex (index: item: ''
      ${templates.post.preview item}
      ${optionalString (isEven index) ''<div class="clearfix"></div>''}
    '') page.items}
    </div>
    ${templates.bootstrap.pagination { inherit (page) pages index; }}
  ''
)
