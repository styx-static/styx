{ lib, templates, conf, ... }:
with lib;
post:
let
  draftIcon = optionalString (attrByPath ["isDraft"] false post) "<span class=\"glyphicon glyphicon-file\"></span> ";
  content = ''
    <div class="post">

      <header class="post-header">
        <div class="text-center">
          <time pubdate="pubdate" datetime="${post.timestamp}">${draftIcon}${prettyTimestamp post.timestamp}</time>
        </div>
      </header>

      <article class="post-content">
        ${post.content}
      </article>

    </div>
  '';
in
  post // { inherit content; }
