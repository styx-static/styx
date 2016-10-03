{ conf, templates, lib, ... }:
with lib;
page:
  templates.base
    { title = conf.siteTitle;
      content = 
        ''
          <div class="row">
            <div class="col-md-12">
              <ul class="list-unstyled past-issues">
                <li class="nav-header disabled"><h2>Posts</h2></li>

                ${concat templates.post.list page.posts}

                ${optionalString (page.nextPage != null) ''
                  <a href="${page.nextPage}">older &rarr;</a>
                ''}

                ${optionalString (page.nextPage != null) ''
                <li class="text-right">
                  <a href="${conf.siteUrl}/archives.html">View more &rarr;</a>
                </li>
                ''}

              </ul>
              <p>Subscribe <a href="${conf.siteUrl}/atom.xml">via RSS</a></p>
            </div>
          </div>
        '';
    }
