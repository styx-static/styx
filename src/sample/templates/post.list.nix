{ conf, lib, ... }:
with lib;
post:
  ''
    <li>
      <div class="row post-title">
        <div class="col-md-12">
          <p class="text-muted time-prefix">
            <time pubdate="pubdate" datetime="${post.timestamp}">${prettyTimestamp post.timestamp}${optionalString (attrByPath ["isDraft"] false post) " <span class=\"glyphicon glyphicon-edit\"></span>"}</time>
          </>
          <p><a href="${conf.siteUrl}/${post.href}">${post.title}</a></p>
        </div>
      </div>
    </li>
  ''
