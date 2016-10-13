{ conf, templates, lib, ... }:
with lib;
page:

let
  content = 
    ''
      <div class="row">
        <div class="col-md-9">
          <h1>${page.title}${optionalString (page.index > 1) " - ${toString page.index}"}</h1>
          <ul class="list-unstyled past-issues">
            ${mapTemplate templates.post.list page.items}
          </ul>
        </div>
        ${templates.partials.sidebar}
      </div>
      ${templates.partials.pagination { pages = page.pages; index = page.index; }}
    '';
in
  page // { inherit content; }
