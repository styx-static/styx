{ conf, templates, lib, ... }:
with lib;
page:

let
  content = 
    ''
      <h1>${page.title}</h1>
      <ul class="list-unstyled">
        ${mapTemplateWithIndex (index: item: ''
          ${templates.post.preview item}
          ${optionalString (isEven index) templates.partials.clearfix}
        '')page.items}
      </ul>
      ${templates.partials.clearfix}
      ${templates.partials.pagination { pages = page.pages; index = page.index; }}
    '';
in
  page // { inherit content; }
