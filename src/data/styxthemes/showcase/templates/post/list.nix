{ conf, lib, ... }:
with lib;
post:
let
  draftIcon = optionalString (attrByPath ["isDraft"] false post) "<span class=\"glyphicon glyphicon-file\"></span> ";
in
  ''
    <li>
      <div class="row post-title">
        <div class="col-md-12">
          <p class="text-muted time-prefix">
            <time pubdate="pubdate" datetime="${post.date}">${with (parseDate post.date); "${D} ${b} ${Y}"}</time>
          </>
          <p><a href="${conf.siteUrl}/${post.href}">${draftIcon}${post.title}</a></p>
        </div>
      </div>
    </li>
  ''
