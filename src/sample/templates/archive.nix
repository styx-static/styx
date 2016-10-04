{ templates, conf, lib, ... }:
with lib;
page:
  templates.base
  { title = "This Week in NixOS";
    content =
      ''
        <div class="row">
          <div class="col-md-12">
            <ul class="list-unstyled past-issues">
              <li class="nav-header disabled"><h2>Post archives - ${toString page.index}</h2></li>
              ${mapTemplate templates.post.list page.items}
            </ul>
          </div>
        </div>
        ${templates.pagination { pages = page.pages; index = page.index; }}
      '';
  }

        /*
        */
