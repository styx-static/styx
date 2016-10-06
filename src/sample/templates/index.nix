{ conf, templates, lib, ... }:
with lib;
page:

let
  content = 
    ''
      <div class="row">
        <div class="col-md-12">
          <ul class="list-unstyled past-issues">
            <li class="nav-header disabled"><h2>Last Posts</h2></li>

            ${mapTemplate templates.post.list page.posts}

            <li class="text-right">
              <a href="${conf.siteUrl}/${page.archivePage.href}">Archives &rarr;</a>
            </li>

          </ul>
          <p>Subscribe <a href="${conf.siteUrl}/${page.feed.href}">via RSS</a></p>
        </div>
      </div>
    '';
in
  page // { inherit content; }
