{ lib, templates, conf, ... }:
with lib;
post:
  templates.base
    { title = "${post.title} - ${conf.siteTitle}";
      content = ''
        <div class="post">

          <header class="post-header">
            <div class="text-center">
              <time pubdate="pubdate" datetime="${post.timestamp}">${prettyTimestamp post.timestamp}${optionalString (attrByPath ["isDraft"] false post) " <span class=\"glyphicon glyphicon-edit\"></span>"}</time>
            </div>
          </header>

          <article class="post-content">
            ${post.html}
          </article>

        </div>
      '';
    }
