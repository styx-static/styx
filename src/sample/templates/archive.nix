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
              <li class="nav-header disabled"><h2>Past posts</h2></li>

              ${concat templates.post.list page.posts}

              ${optionalString (page.prevPage != null) ''
                <a href="${page.prevPage}">&larr; newer</a>
              ''}

              ${optionalString (page.nextPage != null) ''
                <a href="${page.nextPage}">older &rarr;</a>
              ''}

            </ul>
          </div>
        </div>
      '';
  }
